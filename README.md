<div align="center">

# Generador de Horarios

### Archivo histórico de un proyecto en Turbo Pascal · 1995-1996

[![Pascal](https://img.shields.io/badge/Pascal-Turbo_6%2F7-E3F171?style=for-the-badge&logo=delphi&logoColor=white&labelColor=662A0A)](src/HORA.PAS)
[![Platform](https://img.shields.io/badge/Platform-MS--DOS-555?style=for-the-badge&logo=dos&logoColor=white)](docs/COMPILACION.md)
[![Graphics](https://img.shields.io/badge/Graphics-VGA_640%C3%97480_BGI-1E90FF?style=for-the-badge)](docs/ARQUITECTURA.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

[![Era](https://img.shields.io/badge/era-1995--1996-8A2BE2?style=flat-square)](docs/HISTORIA.md)
[![Status](https://img.shields.io/badge/status-archivo_hist%C3%B3rico-success?style=flat-square)](#)
[![Lang](https://img.shields.io/badge/docs-espa%C3%B1ol-red?style=flat-square)](#)
[![Encoding](https://img.shields.io/badge/encoding-CP850-orange?style=flat-square)](docs/FORMATO-DATOS.md)
[![Code preserved](https://img.shields.io/badge/c%C3%B3digo-byte--id%C3%A9ntico-blue?style=flat-square)](docs/SANEAMIENTO.md)
[![Sanitized](https://img.shields.io/badge/PII-saneada-green?style=flat-square)](docs/SANEAMIENTO.md)

**Generador combinatorio de horarios universitarios sin cruces**
*hecho en MS-DOS, recuperado después de ~30 años*

[Historia](docs/HISTORIA.md) ·
[Arquitectura](docs/ARQUITECTURA.md) ·
[Formato de datos](docs/FORMATO-DATOS.md) ·
[Cómo compilar](docs/COMPILACION.md) ·
[Saneamiento de datos](docs/SANEAMIENTO.md)

</div>

---

> **Autor original:** Oscar Zamora Plasencia · **ZmS Software** © 1995-1996
> **Sitio del autor:** [ozamora.com](https://ozamora.com)
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

## El mouse: cazado en la versión final

Durante mucho tiempo creí recordar que la última versión del programa	enía soporte completo de mouse. Cuando revisamos el código fuente
preservado en [src/](src/) (HORA11, 16-abr-1996), nada cuadraba:

- `HORA.PAS` declara `uses crt, graph, uhora, uhora2;` — sin `mouse`.
- 11 `readkey` y 47 códigos de tecla literales — todo por teclado.
- El manual de HORA11 no menciona el ratón en ningún tópico.

La unidad [src/MOUSE.PAS](src/MOUSE.PAS) (driver INT 33h del BIOS con 10
cursores gráficos) estaba presente desde feb-1996, pero **sin enlazar**.

Resulta que **sí terminé de integrarla**. La evidencia apareció en un
backup de OneDrive bajo `_Archived_/DOS Applications/Horarios/`: el
**ejecutable compilado del 1 de junio de 1996** — 6 semanas posterior
al source preservado — con:

- ✅ Opcode `INT 33h` (`CD 33`) presente en bytecode
- ✅ Tópico "Usando el Mouse" en el manual `GDH.HLP` actualizado
- ✅ 7 menciones de "mouse", 14 de "click", 8 de "botón" en el manual
- ✅ Menú renombrado: "Adicionar Curso" → "Adicionar Sección" (más correcto)
- ✅ 24 tópicos de ayuda vs 21 del HORA11 anterior

**El código fuente de esa versión final nunca se conservó.** Solo
sobrevivió el EXE compilado. Ahora está en
[release/1996-06-FINAL/](release/1996-06-FINAL/) junto al manual y los
drivers BGI necesarios para ejecutarlo en DOSBox.

Ver [release/1996-06-FINAL/README.md](release/1996-06-FINAL/README.md)
para el detalle.

---

## ¿Qué hay aquí?

Este repositorio preserva **cuatro snapshots** del proyecto a lo largo de su
evolución, más documentación moderna para entenderlo sin necesidad de
ejecutarlo en DOS.

| Carpeta | Contenido | Propósito |
|---|---|---|
| [release/1996-06-FINAL/](release/1996-06-FINAL/) | **EXE final** v1.1 con mouse (jun 1996) | Última versión distribuida — fuente perdida |
| [src/](src/) | Versión **HORA11** (abril 1996, v1.1 pre-final) | Último source preservado, sin mouse integrado |
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
├── release/
│   └── 1996-06-FINAL/               ⭐ EXE final con mouse (1 jun 1996) — fuente perdida
├── src/                            ★ HORA11 — último source preservado (16 abr 1996)
├── history/
│   ├── 1995-08-HORABETA/           v1.0 Beta
│   ├── 1995-09-HORA10/             v1.0 estable
│   └── 1996-02-BETA96/             Beta 96
├── docs/
│   ├── HISTORIA.md
│   ├── ARQUITECTURA.md
│   ├── FORMATO-DATOS.md
│   ├── COMPILACION.md
│   ├── SANEAMIENTO.md
│   ├── CAMBIOS-ORIGINALES.txt
│   └── codigo/                     Docs por unidad: HORA, HORARIO, UHORA, UHORA2, MOUSE
├── scripts/sanitize-data.ps1
├── .vscode/                        Asocia .PAS a Pascal con encoding CP850
├── .gitignore
└── .gitattributes
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
- **Entrada:** 100% por teclado (flechas, Tab, Enter, Esc, F1, F5)

Ver [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md) para el detalle completo.

## El mouse que no llegué a integrar

En febrero de 1996 (BETA96) agregué al proyecto la unidad
[src/MOUSE.PAS](src/MOUSE.PAS): un driver completo que habla con el ratón
vía **INT 33h** del BIOS, con 10 cursores gráficos personalizados
(flecha, reloj de arena, mano apuntando, check, etc.). El objetivo era
claro: la siguiente versión del programa iba a soportar mouse — click
sobre la grilla 15×6 para marcar horas, drag para mover secciones,
botones presionables con el cursor.

La unidad nunca se llegó a enlazar. Verificable hoy:

- [src/HORA.PAS](src/HORA.PAS) declara `uses crt, graph, uhora, uhora2;`
  — sin `mouse`.
- 11 llamadas a `readkey` y 47 códigos de tecla literales en el código:
  toda la interacción es por teclado.
- El manual [src/GDH.HLP](src/GDH.HLP) (21 tópicos) no menciona el ratón
  en ninguna parte.

Quedó como el roadmap nunca ejecutado de la v1.2 que no existió.
Ver [docs/codigo/MOUSE.PAS.md](docs/codigo/MOUSE.PAS.md) para el detalle
de la unidad.

---

<div align="center">

### Sobre el autor

**Oscar Zamora Plasencia**
[![Web](https://img.shields.io/badge/ozamora.com-000000?style=for-the-badge&logo=safari&logoColor=white)](https://ozamora.com)
[![GitHub](https://img.shields.io/badge/@oscarzamora-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/oscarzamora)

Ingeniero de Sistemas · Universidad de Lima · Promoción 1998

---

*"Quizás el algoritmo de detección de cruces le sirva a alguien.*
*Quizás no. Pero ya no se queda en un ZIP guardado en OneDrive."*

</div>
