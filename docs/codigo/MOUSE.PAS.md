# Documentación: `MOUSE.PAS`

> Unidad de **driver de ratón** vía interrupción 33h del BIOS. Aporta
> también un catálogo de cursores personalizados.
>
> Archivo: [src/MOUSE.PAS](../../src/MOUSE.PAS) · 5 884 bytes · CP850 · CRLF
> **Sin cambios desde 31-may-1994.** Probablemente proviene de una fuente
> externa (BBS / colección de utilidades) — no menciona autor.
>
> Disponible en BETA96 y HORA11, pero **no usada** por `HORA.PAS` ni `HORARIO.PAS`.

## Encabezado

```pascal
unit Mouse;
interface
uses crt, dos;
var regs : registers;
```

`registers` es el record predefinido en la unidad `dos` de Turbo Pascal,
con campos `ax, bx, cx, dx, es, ds, …`. La variable `regs` es **global a
la unidad** (no thread-safe, pero DOS real-mode tampoco lo es).

## API pública

### Funciones de existencia y estado

| Símbolo | Firma | Función |
|---|---|---|
| `MouseExist` | `function : boolean` | Detecta si hay driver de ratón cargado (INT 33h/00h) |
| `MouseOn` | `procedure` | Muestra el cursor (INT 33h/01h) |
| `MouseOff` | `procedure` | Oculta el cursor (INT 33h/02h) |
| `MouseX` | `function : integer` | Coordenada X del cursor en pixels (INT 33h/03h) |
| `MouseY` | `function : integer` | Coordenada Y del cursor en pixels |
| `Mouseln(a, b, c, d)` | `function : boolean` | true si cursor está dentro del rect `(a,b)-(c,d)` |
| `MouseDown(n)` | `function : boolean` | true si el botón `n` está presionado |

### Control de cursor

| Símbolo | Función |
|---|---|
| `PutMouse(x, y)` | Posiciona el cursor en `(x, y)` (INT 33h/09h) |
| `LimitMouse(x1, y1, x2, y2)` | Restringe el área de movimiento (INT 33h/07h + 08h) |
| `graphicMouseCursor(xHotPoint, yHotPoint, dataOfs)` | Carga un cursor gráfico personalizado |

### Cursores predefinidos

Cada uno llama a `graphicMouseCursor` con datos `[0..31] of word`
(máscara AND × 16 + máscara XOR × 16, formato estándar de mouse driver):

| Símbolo | Cursor |
|---|---|
| `setArrowCursor` | Flecha (default) |
| `setWatchCursor` | Reloj de muñeca |
| `setNewWatchCursor` | Reloj alterno |
| `setHourGlassCursor` | Reloj de arena |
| `setCheckMarkCursor` | Marca de verificación ✓ |
| `setPointingHandCursor` | Mano apuntando 👆 |
| `setUpArrowCursor` | Flecha hacia arriba |
| `setLeftArrowCursor` | Flecha izquierda ← |
| `setDiagonalCrossCursor` | Cruz diagonal |
| `setRectangularCrossCursor` | Cruz rectangular + |

## Cómo funciona

`Callmouse` es el helper privado:

```pascal
procedure Callmouse;
begin
  intr(51, regs);   { 51 decimal = 33h hexadecimal }
end;
```

Todas las funciones públicas:
1. Cargan parámetros en `regs.ax` (número de función) y otros registros.
2. Llaman a `Callmouse` → invoca `intr(33h, regs)`.
3. Leen el resultado de `regs.bx`, `cx`, `dx`, etc.

Es la API estándar de Microsoft Mouse Driver (compatible con
CuteMouse, Logitech, etc.). Documentada en *Microsoft Mouse Programmer's
Reference* (1991).

## Por qué no se usa en el `HORA.PAS` preservado

El menú de [src/HORA.PAS](../../src/HORA.PAS) es **completamente por teclado**:
flechas, Enter, Esc, Tab, F1, F5. Buscando en el código:

```bash
grep -i 'mouse\|uhora' src/HORA.PAS
```

`HORA.PAS` declara `uses crt, graph, uhora, uhora2;` — **no incluye `mouse`**.

Pero el mouse **sí se llegó a integrar** en la versión final del programa
(1 de junio de 1996), preservada como EXE compilado en
[release/1996-06-FINAL/](../../release/1996-06-FINAL/). El código fuente
de esa integración nunca se archivó — lo que queda es:

- HORA11 (abr-1996, este repo en `src/`): unidad presente pero sin enlazar.
- v1.1 FINAL (jun-1996, en `release/`): EXE compilado con `INT 33h` (`CD 33`)
  enlazado y manual con tópico "Usando el Mouse".

Esta unidad es exactamente la que fue enlazada al EXE final.

## Limitaciones

- **Solo funciona en MS-DOS real-mode** (o en DOSBox con `mouse` cargado).
  En Windows nativo no hay INT 33h.
- En FPC para Windows/Linux, `intr` no existe → no compila tal cual.
- El bug de `PutMouse` (no llama a `Callmouse` después de cargar
  registros) está presente en el código original — `PutMouse` no
  posiciona realmente el cursor:

  ```pascal
  procedure PutMouse(x, y : integer);
  begin
    regs.ax := 9;
    regs.bx := x;
    regs.cx := y;
    { ⚠️ falta: callmouse; }
  end;
  ```

  Probablemente nunca se notó porque la función no se usa.

> Los bugs históricos **se preservan**. No se corrigen.

## Datos del cursor (formato Microsoft Mouse)

Cada cursor son **32 words** (64 bytes):
- Words 0-15: **máscara AND** (16×16 bits) — se aplica con AND a la pantalla
- Words 16-31: **máscara XOR** — se aplica con XOR sobre el resultado

El resultado visible es:
```
pixel_final = (pixel_pantalla AND mascara_and) XOR mascara_xor
```

`xHotPoint`/`yHotPoint` definen el píxel "activo" dentro del 16×16.

## Dependencias

- `crt` — solo `directVideo` (deshabilitado temporalmente en `MouseExist`)
- `dos` — `registers`, `intr`
