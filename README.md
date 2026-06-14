# Generador de Horarios — Archivo Histórico (1995-1996)

> Programa académico en **Turbo Pascal** que genera todas las combinaciones válidas
> de horarios universitarios sin cruces, dados un conjunto de cursos y secciones.
>
> **Autor original:** Oscar Zamora Plasencia · **ZmS Software** © 1995-1996
> **Plataforma original:** MS-DOS · VGA · Turbo Pascal 6/7 · BGI Graphics
> **Estado:** Archivo histórico preservado. No se modifica el código fuente.

---

## El origen (1995)

> Tercer año de **Ingeniería de Sistemas** en la **Universidad de Lima**, 1995.

Inscribirse a los cursos cada semestre era una experiencia frustrante:

- Llegabas al día de la matrícula con tu combinación ideal armada a mano,
  a lápiz, sobre una cuadrícula impresa.
- En la cola, una clase estaba **llena o cerrada** y todo el horario se caía.
- Había que **rearmar combinaciones al vuelo**, sin cruces, con la cola
  detrás y el reloj corriendo.
- Encontrar otra combinación válida en minutos, manualmente, era casi imposible.
  Más de una vez terminé matriculado en lo que sobraba, no en lo que quería.

La idea fue simple: **hacer todas las permutaciones por adelantado**. Que el
programa genere *todas* las combinaciones válidas (sin cruces) **antes** de
ir a la matrícula, para llegar con un plan A, B, C, D… y si una sección se
cae, saltar a la siguiente combinación ya lista.

El "foco se prendió" mientras hacía guardias como **veedor en la sala de
cómputo** de la facultad — entre turnos sin mucho que hacer, iterando ideas,
terminé de armar el algoritmo iterativo que evita la recursión y detecta
cruces con un bitmap 15×6 (horas × días).

## La conversación de 1998 que no pasó

En 1998 la universidad me pidió el **código fuente**. Decidí no entregarlo —
quizás pensando en algún retorno financiero que nunca iba a llegar. Hoy, casi
**30 años después**, sé que probablemente no fue la decisión más acertada.

Por eso ahora lo publico como **archivo histórico**: fidedigno al original,
con su Turbo Pascal y sus comentarios en español con CP850.
Quizás el algoritmo de detección de cruces le sirva a alguien. Quizás no.
Pero ya no se queda en un ZIP guardado en OneDrive.

## Sobre la eficiencia del algoritmo (corroboración técnica)

El benchmark documentado verbatim en [src/GDH.HLP](src/GDH.HLP) reporta:

> 5 cursos · 84 secciones · **861 840** combinaciones evaluadas en
> **3 min 20 s** sobre un 486DLC a 40 MHz con SMARTDRV →
> **125 030 horarios válidos** generados · archivo temporal de **11.5 MB**.

Las cifras dan:

- **~4 309 combinaciones evaluadas por segundo**
- **~625 records válidos escritos a disco por segundo**

Para un 486DLC de 1995 (≈6-8 MIPS escalar, disco mecánico con caché de
software SMARTDRV), el programa está cerca del **límite teórico de I/O**:
el caché absorbe los writes y la CPU casi no se aburre. El manual cita
"alrededor de 1000 combinaciones/s" como cifra conservadora, pero el caso
real medido es ~4× más rápido.

Las decisiones de diseño que lo hicieron eficiente (verificables en
`procedure genera` de [src/HORA.PAS](src/HORA.PAS)):

| Decisión | Por qué importa en 1995 |
|---|---|
| **Enumeración iterativa** (no recursiva) | El stack era de 64 KB; recursión profunda en 15 cursos hubiera reventado el modelo de memoria DOS |
| **Contador multi-base** sobre `top[1..totcur]` | Genera el producto cartesiano sin construir el árbol — memoria O(totcur) en vez de O(combinaciones) |
| **Detección de cruce con bitmap 15×6** | Cada celda es O(1); detecta colisión apenas ocurre, no al final |
| **Early-exit en cruce** (`cruce := true`) | Apenas detecta una colisión deja de marcar el resto de horas |
| **Salida streaming a disco** (`file of regcuadre`) | 125 030 horarios × 96 bytes = 12 MB → imposible en los 640 KB de memoria conventional de DOS |
| **Reutilizar `vaciohor` como baseline del bitmap** | Las "horas no deseadas" se aplican gratis, no como filtro post-hoc |
| **Records compactos** (96 bytes/horario, reducidos desde 176 en la Beta) | Reduce I/O y tamaño del archivo temporal en ~45% |

Hoy el mismo cálculo correría en milisegundos en cualquier laptop, pero la
**estructura del algoritmo sigue siendo la correcta**: iterativo, bitmap
de colisión, early-exit, streaming. Es básicamente lo que un solver moderno
haría con las mismas restricciones de memoria embebida.

---

## ¿Qué hay aquí?

Este repositorio preserva **cuatro snapshots** del proyecto a lo largo de su
evolución, más documentación moderna para entenderlo sin necesidad de
ejecutarlo en DOS.

| Carpeta | Contenido | Propósito |
|---|---|---|
| [src/](src/) | Versión **HORA11** (abril 1996, v1.1) | Versión final / principal |
| [history/1995-08-HORABETA/](history/1995-08-HORABETA/) | v1.0 Beta — agosto 1995 | Primera versión conservada |
| [history/1995-09-HORA10/](history/1995-09-HORA10/) | v1.0 estable — septiembre 1995 | Incluye `CAMBIOS.TXT` original |
| [history/1996-02-BETA96/](history/1996-02-BETA96/) | Beta 96 — febrero 1996 | Introduce `HORA.PAS` y `MOUSE.PAS` |
| [docs/](docs/) | Documentación moderna | Historia, arquitectura, formatos, cómo compilar |

## Documentación

- [docs/HISTORIA.md](docs/HISTORIA.md) — línea de tiempo 1995→1996 y cambios verificados entre snapshots
- [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md) — módulos, dependencias, estructuras de datos
- [docs/FORMATO-DATOS.md](docs/FORMATO-DATOS.md) — layout binario de `.DAT`, `.HOR` y formato de `.HLP`
- [docs/COMPILACION.md](docs/COMPILACION.md) — cómo compilar/ejecutar hoy (DOSBox + TP7 o Free Pascal)
- [docs/SANEAMIENTO.md](docs/SANEAMIENTO.md) — qué datos personales fueron eliminados o reemplazados y por qué
- [docs/CAMBIOS-ORIGINALES.txt](docs/CAMBIOS-ORIGINALES.txt) — `CAMBIOS.TXT` original preservado en CP850
- [docs/codigo/](docs/codigo/) — documentación externa por cada unidad Pascal

## Estructura

```
horarios/
├── src/                            ★ HORA11 — versión principal (abr 1996)
├── history/
│   ├── 1995-08-HORABETA/           v1.0 Beta
│   ├── 1995-09-HORA10/             v1.0 estable
│   └── 1996-02-BETA96/             Beta 96
├── docs/
│   ├── HISTORIA.md
│   ├── ARQUITECTURA.md
│   ├── FORMATO-DATOS.md
│   ├── COMPILACION.md
│   ├── CAMBIOS-ORIGINALES.txt
│   └── codigo/                     Docs por unidad: HORA, HORARIO, UHORA, UHORA2, MOUSE
├── .vscode/                        Asocia .PAS a Pascal con encoding CP850
├── .gitignore                      Ignora outputs de compilación (.EXE, .TPU, .BAK, gdh.tmp…)
└── .gitattributes                  .PAS/.HLP = texto CRLF · .HOR/.DAT = binario
```

## Convenciones de preservación

- **No se editan los `.PAS` ni `.HLP` originales.**
  Toda la documentación es **externa** (`docs/codigo/*.md`).
- **Los binarios `.DAT` y `.HOR` fueron SANEADOS** — contenían mis horarios
  reales de cada semestre, con los **apellidos reales de mis profesores** y
  el **plan de estudios identificable**. Decidí exponer mi propia historia
  pero no la de terceros. Estructura, tamaño, formato de records y
  timestamps preservados; contenido string reemplazado por placeholders
  sintéticos. Ver [docs/SANEAMIENTO.md](docs/SANEAMIENTO.md).
- **Timestamps preservados** (`LastWriteTime` original de 1995-1996) en todas las copias.
- **Encoding original CP850** (DOS Latin español). VS Code lo reabre correctamente gracias a
  [.vscode/settings.json](.vscode/settings.json).
- **CRLF** mantenido en todos los archivos de texto (proyecto DOS).

## Vistazo rápido al programa

- **Lenguaje:** Turbo Pascal (modo gráfico VGA 640×480 vía unidad `graph` / BGI)
- **Capacidades:** hasta 15 cursos · 25 secciones por curso · 375 secciones totales
- **Algoritmo:** enumeración combinatoria iterativa con bitmap de cruces
  (~4 300 combinaciones/s en un 486DLC a 40 MHz — ver
  [sección de eficiencia](#sobre-la-eficiencia-del-algoritmo-corroboración-técnica))
- **Salidas:** visualización en pantalla + impresión a `LPT1` (horario completo o lista de secciones)
- **Persistencia:** typed files binarios (`file of <record>`), formato propietario
- **Soporte de mouse:** vía INT 33h (driver real de DOS) en versiones BETA96 y HORA11

Ver [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md) para el detalle completo.
