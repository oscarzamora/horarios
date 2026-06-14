# Snapshots Históricos

Cada subcarpeta es una **copia tal cual** del estado del proyecto en un
momento dado, con los `LastWriteTime` originales preservados.

## Índice cronológico

| Snapshot | Fecha aprox. | Versión | Highlights |
|---|---|---|---|
| [1995-08-HORABETA/](1995-08-HORABETA/) | 13-14 ago 1995 | **v1.0 Beta** | Primer snapshot completo. Solo `HORARIO.PAS`. Sin mouse. |
| [1995-09-HORA10/](1995-09-HORA10/) | 10 sep 1995 | **v1.0** estable | Incluye [CAMBIOS.TXT](1995-09-HORA10/CAMBIOS.TXT) con changelog detallado |
| [1996-02-BETA96/](1996-02-BETA96/) | 24 feb 1996 | **Beta 96** | Aparece `HORA.PAS` (nuevo main) y `MOUSE.PAS` |
| (principal en [../src/](../src/)) | 16 abr 1996 | **v1.1** | Versión final preservada — la principal del repo |

## Cómo comparar versiones

### Por nombre de archivo

`HORARIO.PAS` aparece en las 4 versiones, así que puedes diffear su evolución:

```powershell
# Beta vs v1.0 estable
git diff --no-index --stat history/1995-08-HORABETA/HORARIO.PAS history/1995-09-HORA10/HORARIO.PAS

# v1.0 estable vs Beta 96
git diff --no-index --stat history/1995-09-HORA10/HORARIO.PAS history/1996-02-BETA96/HORARIO.PAS

# Beta 96 vs versión final (HORA11)
git diff --no-index --stat history/1996-02-BETA96/HORARIO.PAS ../src/HORARIO.PAS
```

`UHORA.PAS` se estabilizó en sep 1995 y no cambió más:

```powershell
git diff --no-index history/1995-09-HORA10/UHORA.PAS ../src/UHORA.PAS
# (debería estar vacío)
```

`UHORA2.PAS` creció gradualmente:

```powershell
ls history/*/UHORA2.PAS, ../src/UHORA2.PAS | Format-Table Name, Length, LastWriteTime
```

### Por commit (cuando el repo esté en git)

Si organizas commits por snapshot puedes usar:

```powershell
git log --oneline --all -- HORARIO.PAS
```

## Lo que NO está aquí

- Snapshots anteriores a julio-1995 — los encabezados de los `.PAS` antiguos
  citan un rango de copyright "1991 - 1995" heredado del template del header,
  pero el desarrollo verificable de este código arranca en julio-agosto 1995.
- Versiones intermedias entre BETA96 (feb) y HORA11 (abr).
- Cualquier código posterior a abril 1996 — el proyecto se discontinuó tras
  la v1.1.
- Cualquier código posterior a abril 1996 — el proyecto se discontinuó tras
  la v1.1.

## Archivos `*.HOR` y `*.DAT`

Los archivos binarios de datos (`*.HOR`, `*.DAT`) que quedan en cada
snapshot contienen **datos sintéticos de demostración** con la misma
estructura binaria que los originales pero sin información real.

Los archivos originales contenían:

- **Apellidos reales de profesores** en cada registro `reghora`
- **Catálogo real de cursos** identificable por nomenclatura
- **Nombres de archivo `OZ*`/`OZP*`** que exponían iniciales personales y
  semestres académicos

Por eso se sanearon los `.DAT` (reemplazando `nombre` por `CURSO NNNN`) y
los `.HOR` (reemplazando `codigo`, `seccion` y `profesor` por placeholders
secuenciales), y se eliminaron por completo los `OZ*`/`OZP*.HOR`.

Ver [docs/SANEAMIENTO.md](../docs/SANEAMIENTO.md) para detalles
byte-a-byte de qué se modificó.
