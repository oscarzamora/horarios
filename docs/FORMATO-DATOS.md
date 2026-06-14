# Formato de Archivos de Datos

Detalle binario de cada archivo persistente, según los `type record` y los
`file of <record>` declarados en [src/HORA.PAS](../src/HORA.PAS).

## Notas sobre `string[N]` en Turbo Pascal

Turbo Pascal almacena `string[N]` (ShortString) como **N+1 bytes**: el primer
byte es la longitud actual (0..N), seguido de N bytes de contenido. Los bytes
no usados quedan con basura (típicamente bytes de la asignación previa). El
contenido se interpreta en **CP850** (DOS Latin).

## `CURSOS.DAT` (y `CUR.DAT`) — Base de datos de cursos

Declaración:

```pascal
regcur = record
  codigo:  string[5];     {  6 bytes (1 len + 5 chars) }
  nombre:  string[12];    { 13 bytes (1 len + 12 chars) }
  ht:      integer;       {  2 bytes (Turbo integer = 16 bits LE) }
  flag:    char;          {  1 byte                                  }
end;
```

**Tamaño:** 22 bytes por registro.
**Apertura:** `file of regcur` → acceso aleatorio con `seek(filecur, n)`.

| Offset | Bytes | Campo | Notas |
|---:|---:|---|---|
| 0 | 1 | `codigo.length` | 0..5 |
| 1 | 5 | `codigo.content` | CP850, padding sin definir |
| 6 | 1 | `nombre.length` | 0..12 |
| 7 | 12 | `nombre.content` | CP850 |
| 19 | 2 | `ht` | int16 LE, horas/semana (2..12) |
| 21 | 1 | `flag` | `'@'` = registro activo; otro = borrado lógico |

**Reglas de validación** (verificadas en `editcur`):

- `nombre` no puede ser vacío después de `alltrim`.
- `ht ∈ [2, 12]`.
- `codigo` es la clave primaria; no se permiten duplicados.

`CUR.DAT` usa exactamente el mismo formato — aparece desde BETA96 como
copia/respaldo paralelo.

## `*.HOR` — Archivo de horarios del usuario

Declaración:

```pascal
mathora = array[1..24] of integer;   { 48 bytes (24 × int16) }

reghora = record
  codigo:   string[5];   {  6 bytes }
  seccion:  string[4];   {  5 bytes }
  profesor: string[8];   {  9 bytes }
  flag:     char;        {  1 byte  }
  hora:     mathora;     { 48 bytes }
end;
```

**Tamaño:** 69 bytes por registro.
**Apertura:** `file of reghora`.

| Offset | Bytes | Campo | Notas |
|---:|---:|---|---|
| 0 | 1+5 | `codigo` | clave foránea hacia `CURSOS.DAT` |
| 6 | 1+4 | `seccion` | identificador de sección |
| 11 | 1+8 | `profesor` | apellido(s) — solo 8 chars (limitación de la época) |
| 20 | 1 | `flag` | `'@'` = activo |
| 21 | 48 | `hora` | 12 **pares** `(fila, columna)` int16 LE |

### Codificación de `hora: mathora`

El array `hora[1..24]` representa hasta 12 horas de clase como **pares
consecutivos** `(fila, columna)`:

| Índice | Significado | Rango |
|---|---|---|
| `hora[2k-1]` | Fila (7am base) → **fila = hora - 6** | 1..15 (cubre 7am-9pm) |
| `hora[2k]` | Columna del día → 1=Lun … 6=Sáb | 1..6 |

Para un curso con `ht = N` horas, solo los primeros `2N` valores son
significativos. El resto queda con basura inicial.

> **Ejemplo:** Una sección con clases lunes 8-9am y miércoles 10-11am tendría:
> `hora = [2, 1,  4, 3,  0, 0,  0, 0, …]`
> Filas 2 y 4 (8am = 7+1, 10am = 7+3), columnas 1 (lun) y 3 (mié).

### Ejemplos en este repositorio (datos sintéticos)

- [src/PRUEBA.HOR](../src/PRUEBA.HOR) — 1 518 bytes (22 secciones)
- [src/PRUEBA2.HOR](../src/PRUEBA2.HOR) — 5 796 bytes (84 secciones)
- [src/GEN.HOR](../src/GEN.HOR) — 5 934 bytes (86 secciones)

> Todos los `.HOR` que quedan en el repositorio son **datos sintéticos
> generados por el saneamiento** (`codigo = C0001..`, `seccion = S001..`,
> `profesor = DOC0001..`). El array `hora` se preserva del original porque
> contiene sólo números (filas/columnas) sin PII. Ver
> [SANEAMIENTO.md](SANEAMIENTO.md).

## `gdh.tmp` — Temporal de combinaciones generadas

Declaración:

```pascal
regcuadre = record
  seccion: array[1..16] of string[5];   { 16 × (1+5) = 96 bytes }
end;
```

**Tamaño:** 96 bytes por registro.
**Apertura:** `file of regcuadre`. Reescrito **en cada `genera`**.

### Convención del archivo

- **Registro 0 (header):** contiene los **códigos de curso** de los cursos
  seleccionados, terminados por `'@'` como sentinela:
  ```
  rtemp.seccion[1..totcur]  = códigos de curso (string[5] cada uno)
  rtemp.seccion[totcur + 1] = '@'
  ```
- **Registros 1..k (datos):** cada uno almacena las **secciones** elegidas
  (mismo orden de cursos que el header) que forman un horario válido sin
  cruces:
  ```
  rtemp.seccion[1..totcur] = secciones elegidas (string[5] aunque el campo
                              de sección original sea string[4])
  ```

El comentario del `CAMBIOS.TXT` confirma que el tamaño bajó de 176 → 96 bytes
entre Beta y v1.0. El programa puede generar hasta `2 147 483 647` registros
(límite de `longint`) — en la práctica limitado por espacio en disco.

Este archivo se crea en el directorio actual con `assign(cuadres, 'gdh.tmp')`
+ `rewrite` al iniciar `menu`, y queda "huérfano" si el programa se aborta.
Por eso está en [`.gitignore`](../.gitignore).

## `GDH.HLP` — Archivo de ayuda

**Formato:** texto plano CP850, líneas terminadas en CRLF.

Estructura:

```
<título tópico 1>            ← lista de 21 títulos en HORA11 (1 por línea)
<título tópico 2>
…
<título tópico N>
0                            ← línea con solo '0' = fin de la lista
001                          ← código del tópico 1 (3 dígitos)
<contenido tópico 1>
<…múltiples líneas…>
0                            ← fin del tópico (cualquier línea que empiece con '0')
002
<contenido tópico 2>
…
```

**Parser** (en `procedure ayuda` de [src/HORA.PAS](../src/HORA.PAS)):

1. Lee la primera sección como **lista de opciones** hasta encontrar una
   línea que empiece con `'0'`.
2. Si `num = 0`, muestra `selectitem` para que el usuario elija; sino salta
   directo al tópico `num`.
3. Construye `search := '0' + zfill(num, 2)` (`'001'`..`'099'`) y busca esa
   línea.
4. Imprime con `outtextxy` línea por línea hasta el siguiente `'0…'`.

### Caracteres semigráficos

En el texto se usan caracteres del set extendido CP850 para "bullets" y
adornos (rango 0xB0-0xDF y 0xA0-0xAF):

| CP850 hex | Glyph | Uso típico |
|---|---|---|
| 0xA0 | á | acento |
| 0xA1 | í | acento |
| 0xA2 | ó | acento |
| 0xA3 | ú | acento |
| 0xA4 | ñ | letra ñ |
| 0xB0-0xB3 | ░ ▒ ▓ ▌ | sombreados / bordes |
| 0xB4-0xDF | ┤ ╣ ║ ╗ ╝ ┘ ┐ ┌ └ ┴ ┬ ├ ─ ┼ … | cajas y separadores |
| 0xE0-0xEF | α β Γ π Σ σ µ τ Φ Θ Ω δ ∞ φ ε ∩ | griegas / matemáticas |

Si VS Code muestra `�` o `¢`, abre el archivo con **"Reopen with Encoding →
DOS (CP850)"**. La configuración por defecto en
[.vscode/settings.json](../.vscode/settings.json) ya aplica CP850 a los
`.PAS`; para `.HLP` queda como texto plano UTF-8 por defecto y debe reabrirse
manualmente.

## Nota sobre `*.BAK` del IDE Turbo Pascal

Los snapshots originales incluían backups automáticos generados por el IDE
(extensión `.BAK`, mismo formato que `.PAS`). Fueron **removidos del
repositorio** durante la limpieza para publicación porque eran redundantes
con los snapshots organizados por carpeta en [../history/](../history/),
que ya capturan la evolución del código en sus puntos verificables.
