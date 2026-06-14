# Historia del Proyecto

Línea de tiempo del **Generador de Horarios** según evidencia directa en los
encabezados de los archivos `.PAS` y en el `CAMBIOS.TXT` original.

## Resumen cronológico

| Fecha | Snapshot | Versión declarada | Hito |
|---|---|---|---|
| **31-jul-1995** | _(no preservado)_ | — | Aparece `UHORA2.PAS` v1 (utilidades de texto, 1 716 bytes) |
| **02-ago-1995** | _(no preservado)_ | — | Aparece `UHORA.PAS` v1 (BGI: ventanas, botones, msgbox) |
| **13-14 ago 1995** | [history/1995-08-HORABETA/](../history/1995-08-HORABETA/) | **v1.0 Beta** | Primer snapshot completo conservado |
| **10-sep-1995** | [history/1995-09-HORA10/](../history/1995-09-HORA10/) | **v1.0** estable | Incluye `CAMBIOS.TXT` con changelog detallado vs. Beta |
| **24-feb-1996** | [history/1996-02-BETA96/](../history/1996-02-BETA96/) | **Beta 96** | Aparece `HORA.PAS` (nuevo main) y `MOUSE.PAS` (INT 33h) |
| **16-abr-1996** | [src/](../src/) (HORA11) | **v1.1** | Versión final preservada. `HORA.PAS` evolucionado, `GDH.HLP` ampliado a 21 tópicos |

## Antes de los snapshots conservados

Los encabezados de [history/1995-08-HORABETA/HORARIO.PAS](../history/1995-08-HORABETA/HORARIO.PAS)
llevan un copyright con rango `1991 - 1995`:

```pascal
{ Generador de Horarios versión 1.0.            }
{ Versión en Modo Gráfico.                      }
{ Elaborado por: Oscar Zamora Plasencia         }
{          Copyright (C) ZmS Software, 1991 - 1995 }
```

Ese rango era el del template de header del IDE, no refleja inicio activo
del programa. El desarrollo verificable de este código arranca en
**julio-agosto 1995** (fechas reales de `UHORA2.PAS` y `UHORA.PAS`), así
que ese es el inicio efectivo del proyecto que se preserva aquí.

La unidad [history/1996-02-BETA96/MOUSE.PAS](../history/1996-02-BETA96/MOUSE.PAS)
tiene fecha **31-may-1994** y no menciona autor — probablemente proviene de una
fuente externa (BBS / colección de utilidades de la época) y fue integrada
recién en BETA96.

## Agosto 1995 · HORABETA — v1.0 Beta

Snapshot: [history/1995-08-HORABETA/](../history/1995-08-HORABETA/)

| Archivo | Tamaño | Notas |
|---|---|---|
| `HORARIO.PAS` | 35 244 | Programa principal (modo gráfico) |
| `UHORA.PAS` | 15 884 | Unidad de UI (BGI) |
| `UHORA2.PAS` | 1 716 | Utilidades de texto |
| `GDH.HLP` | 1 471 | Ayuda mínima |
| `CURSOS.DAT` | 528 | Base de datos de cursos (saneada) |

> Los archivos `.HOR` originales de esta versión fueron eliminados por
> contener apellidos reales de profesores. Ver
> [docs/SANEAMIENTO.md](SANEAMIENTO.md).

Características de la v1.0 Beta (extraídas del `CAMBIOS.TXT` posterior, ver
sección siguiente):

- Menú con 14 opciones, separando "Crear / Cargar / Cerrar Horario"
- "Adicionar/Editar/Ver Sección" y "Adicionar/Editar/Ver Curso" eran opciones únicas
- Sin soporte de mouse
- Sin marcado de "horas no deseadas"
- Hasta 32 767 horarios por archivo (límite de `integer`)
- Records temporales de 176 bytes por horario generado

## Septiembre 1995 · HORA10 — v1.0 estable

Snapshot: [history/1995-09-HORA10/](../history/1995-09-HORA10/)

Aporta el archivo [history/1995-09-HORA10/CAMBIOS.TXT](../history/1995-09-HORA10/CAMBIOS.TXT)
(también preservado en [CAMBIOS-ORIGINALES.txt](CAMBIOS-ORIGINALES.txt)).

### Cambios verificados vs. v1.0 Beta (extracto del changelog original)

**Correcciones:**

- Generación con archivo vacío ya no crea un temporal ilimitado.
- Impresión sin impresora conectada se puede cancelar.
- Borrar curso ya no deja línea en blanco en la información.
- Generar con 1-2 secciones ya no añade combinaciones inválidas.
- Mensaje correcto cuando no hay cursos en la base.
- Definición de horas con bloques equivocados ahora se puede cancelar.

**Modificaciones de menú:**

- `Crear Horario` + `Cargar Horario de Disco` → fusionados en `Nombre del Archivo`
  (detecta automáticamente si es nuevo o existente).
- `Cerrar Horario` → eliminado (la grabación es automática).
- `Adicionar/Editar/Ver Sección` → dividido en `Adicionar Curso` y `Modificar Curso`.
- `Adicionar/Editar/Ver Curso` → dividido en `Adicionar Curso a la Base` y
  `Modificar Curso de la Base`.
- `Información del Horario` → renombrado a `Información del Archivo`.
- `Información de los Cursos` → renombrado a `Cursos en la Base de Datos`.

**Mejoras internas:**

- Records temporales reducidos de **176 → 96 bytes** por horario generado.
- Capacidad ampliada de `32 767` (integer) a `2 147 483 647` (longint) horarios.

**Funcionalidad nueva:**

- Ventana de selección reutilizable (cursos a generar, modificar, borrar, ayuda).
- Impresión de "lista de secciones" además del horario completo.
- **Marcado de horas no deseadas** que se respeta al generar.
- Tecla `<F5>` para saltar a un número de horario específico.
- Ayuda con selector de tópicos.
- Animación de cierre tipo "persianas".

## Febrero 1996 · BETA96

Snapshot: [history/1996-02-BETA96/](../history/1996-02-BETA96/)

| Novedad | Detalle |
|---|---|
| Aparece **`HORA.PAS`** | Nuevo programa principal (46 033 bytes), coexiste con `HORARIO.PAS` |
| Aparece **`MOUSE.PAS`** | Driver de mouse vía `intr(51, regs)` (INT 33h del BIOS) |
| `GDH.HLP` crece | De 10 902 → 11 824 bytes |
| `CUR.DAT` | Nuevo archivo auxiliar de cursos (1 694 bytes) |

`HORARIO.PAS` sigue presente y actualizándose (45 993 bytes, 24-feb-1996), por
lo que `HORA.PAS` empezó como **rama paralela** antes de convertirse en la
versión principal en HORA11.

## Abril 1996 · HORA11 — v1.1 (versión principal)

Snapshot: [src/](../src/)

| Archivo | Tamaño | Diferencia vs. BETA96 |
|---|---|---|
| `HORA.PAS` | **47 303** | +1 270 bytes (creció ~3%) |
| `HORARIO.PAS` | 45 409 | −584 bytes (limpieza) |
| `UHORA.PAS` | 17 675 | Sin cambios desde sep-1995 |
| `UHORA2.PAS` | **2 077** | +264 bytes (funciones añadidas) |
| `MOUSE.PAS` | 5 884 | Sin cambios |
| `GDH.HLP` | **16 227** | +4 403 bytes — ayuda mucho más amplia |
| `CURSOS.DAT` | 2 156 | Base de datos crecida (saneada) |

> El archivo `OZP961.HOR` original (2 898 bytes) fue eliminado por exponer
> iniciales personales en el nombre y apellidos reales en el contenido.
> Ver [docs/SANEAMIENTO.md](SANEAMIENTO.md).

El encabezado de [src/HORA.PAS](../src/HORA.PAS) declara:

```pascal
{ Generador de Horarios versión 1.1.                                 }
{ Versión en Modo Gráfico.                                           }
{ Elaborado por: Oscar Zamora Plasencia                              }
{                            Copyright (C) ZmS Software, 1995 - 1996 }
```

### Por qué `HORA11` es la versión principal

- Es el snapshot más reciente (abr-1996).
- `HORA.PAS` (47 KB) está más completo que cualquier `HORARIO.PAS` anterior.
- `GDH.HLP` documenta 21 tópicos vs. ~14 en versiones previas.
- Incluye soporte de mouse listo.
- Es el último estado conocido del proyecto.

## Sobre los archivos `.HOR` incluidos

Los archivos `*.HOR` que quedan en el repositorio (`PRUEBA.HOR`,
`PRUEBA2.HOR`, `GEN.HOR`) son **datos de demostración sintéticos** generados
para mostrar la estructura binaria del formato sin exponer información real.
Ver [docs/SANEAMIENTO.md](SANEAMIENTO.md) para el detalle de qué se reemplazó.
