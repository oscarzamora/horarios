# Documentación: `UHORA2.PAS`

> Unidad de **utilidades de texto** estilo dBase/xBase. Funciones puras
> sin estado.
>
> Archivo: [src/UHORA2.PAS](../../src/UHORA2.PAS) · 2 077 bytes · CP850 · CRLF
> Crecimiento histórico: 1 716 → 1 813 → 2 077 bytes (HORABETA → BETA96 → HORA11)

## Encabezado

```pascal
unit uhora2;
INTERFACE
uses crt;
```

## API completa

| Símbolo | Firma | Devuelve | Notas |
|---|---|---|---|
| `beep` | `procedure beep` | — | Bip 200 Hz × 30 ms vía `sound`/`nosound` |
| `space` | `function space(num : integer) : string` | string | `N` espacios |
| `upper` | `function upper(cad : string) : string` | string | Convierte a mayúsculas con `upcase` |
| `ltrim` | `function ltrim(cad : string) : string` | string | Recorta espacios a la izquierda |
| `rtrim` | `function rtrim(cad : string) : string` | string | Recorta espacios a la derecha |
| `alltrim` | `function alltrim(cad : string) : string` | string | `ltrim(rtrim(cad))` |
| `trim` | `function trim(cad : string) : string` | string | `upper(alltrim(cad))` |
| `numval` | `function numval(text : string) : real` | real | String → número (0 si falla) |
| `strval` | `function strval(num : real) : string` | string | Número → string sin decimales (`%0.0f`) |
| `left` | `function left(text : string; cant : integer) : string` | string | **Ver advertencia abajo** |
| `right` | `function right(text : string; cant : integer) : string` | string | Últimos `cant` chars |

## Implementación · puntos notables

### `beep`

```pascal
sound(200);
delay(30);
nosound;
```

Bloquea ~30 ms al ejecutarse. En FPC moderno (no DOS), `sound` puede ser
no-op según plataforma.

### `numval` / `strval`

`numval` usa `val(text, num, code)` y descarta `code` — si la conversión
falla, `num` queda con basura y se devuelve un valor potencialmente
indefinido. **En la práctica el programa siempre la combina con `alltrim`
y valida después**, por ejemplo:

```pascal
out[2] := alltrim(upper(out[2]));
if (numval(out[2]) > 12) or (numval(out[2]) < 2) then { error };
```

`strval` formatea con `str(num:0:0, text)` → entero sin decimales. Para
valores no enteros no es apto (pierde precisión).

### `left` — ⚠️ bug histórico

```pascal
function left;
begin
  left := copy(text, 1, length(text) - cant + 1);
end;
```

Esta implementación es **incorrecta**: la fórmula `length(text) - cant + 1`
no devuelve los primeros `cant` caracteres; devuelve los primeros
`length(text) - cant + 1` caracteres. La función correcta sería:

```pascal
left := copy(text, 1, cant);
```

En el código de [src/HORA.PAS](../../src/HORA.PAS) la única llamada a
`left` es:

```pascal
if y > 4 then tempprint[y, 1] := left(strval(y + 5), 1);
```

Donde se quiere "primer carácter de un string de 2 chars como mucho". Con
`y > 4` → `y + 5 > 9` → `strval` retorna 2 chars; entonces
`length - cant + 1 = 2 - 1 + 1 = 2` → devuelve los 2 chars completos. El
bug pasa desapercibido porque en ese contexto el "primer carácter" es
visualmente el mismo que el string completo escrito en 1 celda.

`right` sí está correcta:

```pascal
right := copy(text, length(text) - cant + 1, cant);
```

> Este bug **se preserva** en la documentación como parte del artefacto
> histórico. No se corrige.

## Dependencias

- `crt` — solo `sound`, `nosound`, `delay`, `upcase`
- Funciones de string estándar de Turbo Pascal: `copy`, `length`, `val`, `str`
