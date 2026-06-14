# Documentación: `UHORA.PAS`

> Unidad de **widgets gráficos**: ventanas, botones, listas con scroll,
> formularios y diálogos. Toda la UI del programa pasa por aquí.
>
> Archivo: [src/UHORA.PAS](../../src/UHORA.PAS) · 17 675 bytes · CP850 · CRLF
> **Sin cambios desde sep-1995** (estable las 4 versiones).

## Encabezado

```pascal
unit uhora;
INTERFACE
uses crt, graph, uhora2;

type tpitem  = array[0..375] of string[30];
     tpindex = array[0..375] of boolean;

var p : pointer;   { puntero para captura de imágenes (getimg/putimg) }
```

`tpitem` y `tpindex` permiten hasta **375 elementos** en listas — el mismo
límite que `horarios[]` (15 cursos × 25 secciones).

## API pública

| Símbolo | Tipo | Propósito |
|---|---|---|
| `selectitem(title, cant, maxindex, item, var index)` | `procedure` | Lista con scroll y selección múltiple/única |
| `ventcls(x1, y1, x2, y2, fon, col, tit)` | `procedure` | Limpia interior de ventana (sin redibujar bordes) |
| `ventana(x1, y1, x2, y2, fondo, coltit, titulo)` | `procedure` | Dibuja ventana con marco + barra de título |
| `buton(x, y, long, wide, selec, cad)` | `procedure` | Botón con 4 estados visuales |
| `gettext(wintitle, tot, max, title, var out)` | `procedure` | Formulario multi-campo |
| `clsout` | `procedure` | Animación "persianas" al cerrar el programa |
| `getimg(x1, y1, x2, y2)` | `procedure` | Guarda región de pantalla en `p^` |
| `putimg(x1, y1, x2, y2)` | `procedure` | Restaura región desde `p^` y libera |
| `msgbox(title, selec, cant, texts)` | `function : boolean` | Diálogo modal OK/Cancel |

## Detalle de cada procedimiento

### `ventana(x1, y1, x2, y2, fondo, coltit, titulo)`

Dibuja una ventana rectangular:

- Borde gris (`setfillstyle(1, 7)`) con doble línea negra.
- Barra de título coloreada (`coltit`) con el texto centrado en blanco.
- Llama a `ventcls` al final para inicializar el área interior con `fondo`.

### `ventcls(x1, y1, x2, y2, fon, col, tit)`

Limpia el interior de una ventana ya dibujada **sin tocar bordes**. Útil
para refrescar contenido sin parpadeo del marco.

### `buton(x, y, long, wide, selec, cad)`

Botón estilo Win 3.1 con 4 estados según `selec`:

| `selec` | Estado | Visual |
|---|---|---|
| `0` | Normal | Botón gris con bordes 3D y texto centrado |
| `1` | Foco | Rectángulo punteado alrededor del texto |
| `2` | Presionado | Sombras invertidas + texto desplazado 2px (efecto "click") |
| `3` | Quitar foco | Borra el rectángulo punteado |

Usa `arc()` para esquinas redondeadas, `floodfill` para sombreado 3D.

### `gettext(wintitle, tot, max, title, var out)`

Formulario con múltiples campos de texto. Parámetros:

- `tot` — número de campos (máx 10)
- `max[i]` — longitud máxima del campo `i` (en chars)
- `title[i]` — etiqueta del campo `i`
- `out[i]` — valor inicial / resultado del campo `i`

Navegación: `Tab`/`Shift+Tab` entre campos, flechas dentro del campo,
`Ins` toggle insert/overwrite, `Backspace`, `Del`, `Home`, `End`.

Termina con:
- `Enter` sobre OK → graba `out[]`
- `Esc` o Cancelar → `out[0] := #27` (sentinel)

### `selectitem(title, cant, maxindex, item, var index)`

Lista con scroll vertical y soporte de **selección múltiple**.

- `cant` — número de items en `item[1..cant]`
- `maxindex` — máximo de items seleccionables (1 = selección única)
- `index[i]` — true si el item `i` está seleccionado (entrada Y salida)
- `index[0]` — true si el usuario canceló

Muestra hasta 15 items a la vez. Scrollbar a la derecha calculado
proporcionalmente: `posicion = (extsel + sel) × (165 - 165×15/cant) / cant`.

Items seleccionados en cyan (color 3), no seleccionados en blanco (15).
Teclas: flechas, `Espacio` (toggle selección), `Home`/`End`, `PageUp`/`PageDown`,
`Enter` (OK), `Esc` (cancelar).

### `msgbox(title, selec, cant, texts) : boolean`

Diálogo modal con uno o dos botones.

- `selec = 0` → solo OK (siempre devuelve `true`)
- `selec = 1` → OK + Cancelar (`true` si OK, `false` si Cancelar/Esc)
- `cant` — número de líneas de texto en `texts[0..cant-1]`

Las líneas se centran horizontalmente. La ventana se ancla a la derecha
de la pantalla (`x1 = getmaxx - 490`).

### `clsout`

Animación de cierre "persianas verticales": dibuja líneas verticales
crecientes desde ambos lados hasta cubrir toda la pantalla, luego
`cleardevice`. ~20 frames, sin `delay` explícito (la velocidad depende del CPU).

### `getimg(x1, y1, x2, y2)`

Reserva memoria con `getmem(p, imagesize(x1, y1, x2, y2))` y guarda la
región de pantalla en `p^` con `getimage`. **Modifica la variable global `p`**.

### `putimg(x1, y1, x2, y2)`

Restaura la imagen desde `p^` con `putimage(..., normalput)` y libera con
`freemem`. Las llamadas a `getimg`/`putimg` deben emparejarse — son la
base del modal stack.

## Patrón de uso típico

```pascal
{ Mostrar un diálogo modal preservando el fondo }
getimg(x1, y1, x2, y2);     { 1. guardar fondo                }
ventana(x1, y1, x2, y2, ...); { 2. dibujar el diálogo           }
{ ... interacción ... }
putimg(x1, y1, x2, y2);     { 3. restaurar fondo + liberar mem }
```

Este patrón se usa internamente en `msgbox`, `selectitem` y `gettext`.

## Limitaciones técnicas

- **Una sola variable global `p` para `getimg/putimg`** → no se pueden
  apilar más de un nivel de modales con captura/restauración simultánea.
  Funciona porque el programa siempre cierra el modal interior antes de
  abrir el exterior.
- Tipos `tpitem` y `tpindex` con tamaño fijo `[0..375]` — gasta ~12 KB de
  stack al pasarlos por valor. En la práctica el programa los pasa por
  referencia (`var`) o como parámetro `tpindex` directamente.
- `tpitem` usa `string[30]` → trunca silenciosamente nombres largos.

## Dependencias

- `crt` — `readkey`, `delay`, `sound`, `nosound`
- `graph` — todo: `bar`, `line`, `rectangle`, `arc`, `outtextxy`,
  `settextstyle`, `setcolor`, `setfillstyle`, `setlinestyle`, `getimage`,
  `putimage`, `imagesize`, `floodfill`, `getmaxx`, `getmaxy`, `textwidth`,
  `textheight`
- `uhora2` — `space`, `alltrim`, `beep`
