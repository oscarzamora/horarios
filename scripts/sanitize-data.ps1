[CmdletBinding()]
param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)

# ----------------------------------------------------------------------------
# sanitize-data.ps1
# Reemplaza in-place los campos identificables (nombres de cursos, apellidos
# de profesores) en los archivos binarios .DAT y .HOR del proyecto, dejando
# intactos el tamaño, la estructura de records y los timestamps originales.
#
# Layouts (Turbo Pascal):
#   regcur  (22 bytes): codigo s[5] | nombre s[12] | ht int16 | flag char
#   reghora (69 bytes): codigo s[5] | seccion s[4] | profesor s[8] | flag |
#                       hora array[1..24] of int16 (48 bytes)
#
# ShortString = 1 byte longitud + N bytes contenido (sin terminador).
# ----------------------------------------------------------------------------

$ErrorActionPreference = 'Stop'

function Set-ShortString {
    param(
        [byte[]] $Buffer,
        [int]    $Offset,    # offset del byte de longitud
        [int]    $MaxLen,    # capacidad declarada del string[N]
        [string] $Value
    )
    if ($Value.Length -gt $MaxLen) { $Value = $Value.Substring(0, $MaxLen) }
    $Buffer[$Offset] = [byte]$Value.Length
    # Sobrescribir TODOS los bytes del campo (incluido padding) con 0x20.
    # Esto borra restos de memoria que Turbo Pascal pudo haber dejado en
    # bytes "no usados" más allá del length efectivo.
    for ($j = 0; $j -lt $MaxLen; $j++) {
        if ($j -lt $Value.Length) {
            $Buffer[$Offset + 1 + $j] = [byte][char]$Value[$j]
        } else {
            $Buffer[$Offset + 1 + $j] = 0x20
        }
    }
}

function Invoke-SanitizeDat {
    param([string] $Path)
    if (-not (Test-Path -LiteralPath $Path)) { return }

    $origTime = (Get-Item -LiteralPath $Path).LastWriteTime
    $bytes    = [System.IO.File]::ReadAllBytes($Path)
    $recSize  = 22
    $count    = [int]($bytes.Length / $recSize)

    Write-Host ("  DAT  {0,4} regs - {1}" -f $count, $Path)

    for ($i = 0; $i -lt $count; $i++) {
        $off = $i * $recSize

        # codigo: ShortString[5] en offset 0 → "C0001"..
        Set-ShortString -Buffer $bytes -Offset ($off + 0) -MaxLen 5 `
            -Value ("C{0:D4}" -f ($i + 1))

        # nombre: ShortString[12] en offset 6 → "CURSO 0001"..
        Set-ShortString -Buffer $bytes -Offset ($off + 6) -MaxLen 12 `
            -Value ("CURSO {0:D4}" -f ($i + 1))

        # ht (int16 LE) en offset 19-20: forzar valor neutro (4 horas)
        $bytes[$off + 19] = 0x04
        $bytes[$off + 20] = 0x00

        # flag en offset 21: forzar '@' (activo) para que sea válido
        $bytes[$off + 21] = [byte][char]'@'
    }

    [System.IO.File]::WriteAllBytes($Path, $bytes)
    (Get-Item -LiteralPath $Path).LastWriteTime = $origTime
}

function Invoke-SanitizeHor {
    param([string] $Path)
    if (-not (Test-Path -LiteralPath $Path)) { return }

    $origTime = (Get-Item -LiteralPath $Path).LastWriteTime
    $bytes    = [System.IO.File]::ReadAllBytes($Path)
    $recSize  = 69
    $count    = [int]($bytes.Length / $recSize)

    Write-Host ("  HOR  {0,4} regs - {1}" -f $count, $Path)

    for ($i = 0; $i -lt $count; $i++) {
        $off = $i * $recSize

        # codigo: ShortString[5] en offset 0 → "C0001"..
        Set-ShortString -Buffer $bytes -Offset ($off + 0) -MaxLen 5 `
            -Value ("C{0:D4}" -f ($i + 1))

        # seccion: ShortString[4] en offset 6 → "S001"..
        Set-ShortString -Buffer $bytes -Offset ($off + 6) -MaxLen 4 `
            -Value ("S{0:D3}" -f ($i + 1))

        # profesor: ShortString[8] en offset 11 → "DOC0001"..
        Set-ShortString -Buffer $bytes -Offset ($off + 11) -MaxLen 8 `
            -Value ("DOC{0:D4}" -f ($i + 1))

        # flag en offset 20: forzar '@' para registros 1..N, '_' (no '@')
        # para el registro 0 (Pascal lo trata como header no-leído).
        if ($i -eq 0) {
            $bytes[$off + 20] = [byte][char]'_'
        } else {
            $bytes[$off + 20] = [byte][char]'@'
        }

        # hora (mathora = 24 × int16 = 48 bytes) en offset 21..68:
        # son sólo números (filas/columnas de horas). No exponen PII.
        # Los dejamos intactos para preservar la "forma" del archivo.
    }

    [System.IO.File]::WriteAllBytes($Path, $bytes)
    (Get-Item -LiteralPath $Path).LastWriteTime = $origTime
}

# ============================================================================
# Sanear todos los .DAT
# ============================================================================
$datFiles = @(
    "src\CURSOS.DAT",
    "src\CUR.DAT",
    "history\1995-08-HORABETA\CURSOS.DAT",
    "history\1995-09-HORA10\CURSOS.DAT",
    "history\1996-02-BETA96\CURSOS.DAT",
    "history\1996-02-BETA96\CUR.DAT"
)

Write-Host "`n=== Saneando .DAT (reemplaza nombre de cursos) ===" -ForegroundColor Cyan
foreach ($f in $datFiles) {
    Invoke-SanitizeDat (Join-Path $RepoRoot $f)
}

# ============================================================================
# Sanear los .HOR no-personales (los OZ*/OZP* se borran aparte)
# ============================================================================
$horFiles = @(
    "src\GEN.HOR",
    "src\PRUEBA.HOR",
    "src\PRUEBA2.HOR",
    "history\1995-09-HORA10\GEN.HOR",
    "history\1996-02-BETA96\GEN.HOR",
    "history\1996-02-BETA96\PRUEBA.HOR",
    "history\1996-02-BETA96\PRUEBA2.HOR"
)

Write-Host "`n=== Saneando .HOR (reemplaza profesor por DOCNNNN) ===" -ForegroundColor Cyan
foreach ($f in $horFiles) {
    Invoke-SanitizeHor (Join-Path $RepoRoot $f)
}

# ============================================================================
# Eliminar .HOR con nombre que expone iniciales personales (OZ*, OZP*)
# ============================================================================
$personalHor = @(
    "src\OZP961.HOR",
    "history\1995-08-HORABETA\OZ952A.HOR",
    "history\1995-08-HORABETA\OZ952B.HOR",
    "history\1995-09-HORA10\OZP952.HOR"
)

Write-Host "`n=== Eliminando .HOR con nombre personal (OZ*/OZP*) ===" -ForegroundColor Cyan
foreach ($f in $personalHor) {
    $p = Join-Path $RepoRoot $f
    if (Test-Path -LiteralPath $p) {
        Remove-Item -LiteralPath $p -Force
        Write-Host "  borrado - $f"
    }
}

Write-Host "`nListo." -ForegroundColor Green
