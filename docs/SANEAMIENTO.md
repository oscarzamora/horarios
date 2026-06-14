# Saneamiento de Datos (Data Sanitization)

> Este documento describe **qué datos originales se eliminaron o
> reemplazaron** en los archivos binarios del repositorio, y por qué.
> Los archivos de código fuente Pascal (`.PAS`) y el archivo de ayuda
> (`.HLP`) **no fueron modificados** y mantienen su contenido original tal
> cual.

## Resumen

Los archivos binarios de datos del programa (`.DAT` y `.HOR`) contenían
información personal de terceros y del entorno educativo donde se usó el
programa:

- **Apellidos reales de profesores universitarios** (~70 apellidos
  distintos a lo largo de los snapshots) en el campo `profesor` de los
  records `reghora`.
- **Catálogo de cursos identificable** (códigos de 4 dígitos + nombres
  de cursos del plan de estudios) en `CURSOS.DAT` y `CUR.DAT`.
- **Nombres de archivo con prefijo iniciales del autor + año/semestre
  académico** (patrón `<iniciales><YYS>.HOR`).

Para preservar el valor histórico del proyecto (estructura binaria,
formato de records, tamaños de archivo, evolución cronológica) sin
exponer información personal de terceros, se aplicó el siguiente
saneamiento.

## Acciones aplicadas

### 1. Archivos `.HOR` eliminados (4 archivos)

Por exponer iniciales personales del autor en el nombre del archivo +
semestre académico:

| Snapshot | Archivo eliminado | Tamaño original |
|---|---|---|
| `src/` | `OZP961.HOR` | 2 898 bytes |
| `history/1995-08-HORABETA/` | `OZ952A.HOR` | 966 bytes |
| `history/1995-08-HORABETA/` | `OZ952B.HOR` | 966 bytes |
| `history/1995-09-HORA10/` | `OZP952.HOR` | 1 104 bytes |

### 2. Archivos `.HOR` saneados (7 archivos)

Para cada record de 69 bytes (`reghora`), se sobrescribieron los campos
string con placeholders secuenciales preservando estructura binaria,
tamaño exacto y el array `hora` original:

| Campo | Offset | Tipo | Antes (real) | Después (sintético) |
|---|---|---|---|---|
| `codigo` | 0-5 | `string[5]` | códigos numéricos del plan de estudios | `'C0001'`, `'C0002'`, … |
| `seccion` | 6-10 | `string[4]` | números de sección | `'S001'`, `'S002'`, … |
| `profesor` | 11-19 | `string[8]` | apellidos reales | `'DOC0001'`, `'DOC0002'`, … |
| `flag` | 20 | `char` | `'@'` o garbage | `'@'` (record activo), `'_'` para record 0 |
| `hora` | 21-68 | `array[1..24] of int16` | filas y columnas reales | **preservado** (no contiene PII) |

Archivos afectados:

- `src/GEN.HOR`, `src/PRUEBA.HOR`, `src/PRUEBA2.HOR`
- `history/1995-09-HORA10/GEN.HOR`
- `history/1996-02-BETA96/GEN.HOR`, `PRUEBA.HOR`, `PRUEBA2.HOR`

### 3. Archivos `.DAT` saneados (6 archivos)

Para cada record de 22 bytes (`regcur`), se sobrescribieron:

| Campo | Offset | Tipo | Antes (real) | Después (sintético) |
|---|---|---|---|---|
| `codigo` | 0-5 | `string[5]` | códigos numéricos del plan de estudios | `'C0001'`, `'C0002'`, … |
| `nombre` | 6-18 | `string[12]` | nombres reales del catálogo de cursos | `'CURSO 0001'`, `'CURSO 0002'`, … |
| `ht` | 19-20 | `int16` | horas reales | `4` (placeholder uniforme) |
| `flag` | 21 | `char` | `'@'` u otro | `'@'` (record activo) |

Archivos afectados:

- `src/CURSOS.DAT`, `src/CUR.DAT`
- `history/1995-08-HORABETA/CURSOS.DAT`
- `history/1995-09-HORA10/CURSOS.DAT`
- `history/1996-02-BETA96/CURSOS.DAT`, `CUR.DAT`

### 4. Documentación corregida

Mis archivos `docs/*.md` y `README.md` originales contenían:

- Inferencias sobre nacionalidad / etapa de vida del autor
- Mención de "horarios personales del autor"
- La ruta absoluta `c:\Users\<usuario>\...` (que exponía el username actual de Windows)

Todas estas referencias fueron retiradas. Las únicas menciones que
quedan a `Oscar Zamora Plasencia` son:

- Como **atribución de autoría** del programa original (autorización
  explícita del autor para mantenerlas).
- **Citas verbatim** de comentarios en los `.PAS` originales — preservadas
  como parte del artefacto histórico.

## Lo que NO se modificó

- Todo el **código fuente Pascal**: `*.PAS` en `src/` e `history/*/` se
  mantienen byte-a-byte idénticos al original.
- El **archivo de ayuda** `GDH.HLP` en cada snapshot se mantiene tal
  cual (contiene sólo texto del manual, sin apellidos ni datos personales
  de terceros).
- El archivo `CAMBIOS-ORIGINALES.txt` (changelog del autor) en
  [docs/CAMBIOS-ORIGINALES.txt](CAMBIOS-ORIGINALES.txt) se mantiene
  byte-a-byte idéntico al `CAMBIOS.TXT` original.

## Garantías técnicas del saneamiento

1. **Tamaño preservado:** cada archivo saneado conserva exactamente el
   mismo número de bytes que el original (sólo se sobrescribe contenido,
   no se trunca ni se extiende).
2. **Timestamps preservados:** el `LastWriteTime` de cada archivo
   modificado se restauró a su valor original (1995-1996) tras el saneo.
3. **Estructura preservada:** los offsets, tipos de campo y número de
   records son idénticos a los originales. El programa puede abrirlos
   sin error.
4. **Padding limpio:** los bytes "no usados" dentro de los campos
   `string[N]` (más allá del length efectivo) fueron sobrescritos con
   `0x20` (espacio) para eliminar restos de memoria que Turbo Pascal
   pudiera haber dejado.
5. **Records "header" cubiertos:** el record 0 de cada `.HOR`, que el
   programa Pascal escribe pero nunca lee (ver código de `abrehor` en
   `HORA.PAS`), también fue saneado completamente — aquí solía quedar
   memory garbage que filtraba texto.

## Reproducibilidad

El script que aplica el saneamiento está en
[../scripts/sanitize-data.ps1](../scripts/sanitize-data.ps1) y es
re-ejecutable. Si en algún momento se restauran los originales (por
ejemplo, desde un backup local), basta ejecutarlo de nuevo:

```powershell
cd <repo-root>
.\scripts\sanitize-data.ps1
```

## Verificación

Se ejecutó una búsqueda exhaustiva de ~110 patrones de PII conocidos
(apellidos detectados en los originales + nombres de cursos identificables
+ marcadores institucionales) sobre todos los archivos del repositorio
post-saneamiento. **Cero coincidencias.**
