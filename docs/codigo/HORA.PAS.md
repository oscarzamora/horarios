# Documentación: `HORA.PAS`

> Programa principal de la versión **1.1** (abril 1996). Es la cara
> visible del Generador de Horarios.
>
> Archivo: [src/HORA.PAS](../../src/HORA.PAS) · 47 303 bytes · CP850 · CRLF

## Encabezado

```pascal
program Generador_de_Horarios;
uses crt, graph, uhora, uhora2;
```

Directiva de memoria: `{$M 65520, 0, 655360}`
→ stack 64 KB, heap mínimo 0, **heap máximo 640 KB** (todo el conventional
memory disponible en MS-DOS real-mode).

## Constantes del menú

```pascal
const mn:array[1..14] of string=
  ('Nombre del Archivo',           {  1 → abrehor      }
   'Adicionar Curso',              {  2 → edithor(0)   }
   'Modificar/Verificar Curso',    {  3 → edithor(1)   }
   'Borrar Curso',                 {  4 → edithor(2)   }
   'Información del Archivo',      {  5 → infoarch     }
   'Generar Horarios Posibles',    {  6 → genera       }
   'Ver/Imprimir Horarios',        {  7 → impcuadres   }
   'Adicionar Curso a la Base',    {  8 → editcur(0)   }
   'Modificar Curso de la Base',   {  9 → editcur(1)   }
   'Borrar Curso de la Base',      { 10 → editcur(2)   }
   'Cursos en la Base de Datos',   { 11 → infototcur   }
   'Ayuda',                        { 12 → ayuda(0)     }
   'Acerca de...',                 { 13 → about        }
   'Salir');                       { 14 → salir + cls  }
```

## Variables globales clave

| Variable | Tipo | Rol |
|---|---|---|
| `archhor` | `string` | Nombre del archivo `.HOR` actualmente abierto |
| `cursos` | `array[1..500] of regcur` | Catálogo de cursos cargado en RAM |
| `totregcur` | `word` | Cursos activos en `cursos[]` |
| `horarios` | `array[1..375] of reghora` | Secciones del archivo abierto |
| `totreghor` | `word` | Secciones activas en `horarios[]` |
| `filecur` | `file of regcur` | Handle a `CURSOS.DAT` |
| `filehor` | `file of reghora` | Handle al `.HOR` actual |
| `cuadres` | `file of regcuadre` | Handle a `gdh.tmp` (combinaciones generadas) |
| `posibles` | `boolean` | `true` si ya hay combinaciones generadas válidas |
| `totcuadres` | `longint` | Número de combinaciones generadas |
| `vaciohor` | `array[1..15, 1..6] of boolean` | Horas marcadas como "no deseadas" |
| `tomaitem` | `tpindex` (uhora) | Selección actual de items multi-select |
| `selopt` | `tpitem` (uhora) | Items para mostrar en `selectitem` |
| `posit` | `integer` | Índice de la sección que se está editando |

## Procedimientos públicos

> Orden: el del archivo original. Forward declarations marcadas con _(fwd)_.

### `refresh`
Redibuja toda la UI base: ventanas, 14 botones del menú, panel de archivo
abierto. Llama a `infonom` al final.

### `ayuda(num : integer)` _(fwd)_
Abre `GDH.HLP` y muestra el tópico número `num`. Si `num = 0`, primero
muestra el selector de tópicos (`selectitem` con la lista de títulos leídos
hasta la línea `0`). Maneja la ausencia de `GDH.HLP` con `IOResult`.

### `acthorario`
**Persistencia.** Reescribe completo el archivo `.HOR` actual desde el array
`horarios[1..totreghor]`. Se llama después de cada cambio para evitar perder
datos.

### `infocur(c : string; var n : string; var h : integer)`
Búsqueda lineal en `cursos[]` por código `c`. Devuelve nombre y horas. Si
no existe, `h := 0`.

### `infohor(c, s : string; var n, p : string; var numhora : integer; var horapos : mathora)`
Búsqueda lineal en `horarios[]` por código+sección. Devuelve nombre del
curso, profesor, número de horas y el array `mathora`.

### `SortCursos(lo, hi : integer)`
Quicksort sobre `cursos[lo..hi]` por `nombre`. Usa procedimiento anidado
`QSortC` (estilo Wirth).

### `SortHor(lo, hi : integer)`
Quicksort sobre `horarios[lo..hi]` por `codigo + seccion` concatenados.

### `tabla(op : shortint; numcur : integer; cod, sec : array of string)`
**El widget más complejo.** Renderiza la grilla 15×6 (7 am-9 pm × lun-sáb) y
soporta tres modos según `op`:

- `op = 0` → "Definición de Horas": el usuario marca con barra espaciadora
  las celdas donde va una sección específica. Requiere completar exactamente
  `tothora` celdas. Persiste el resultado en `horarios[posit].hora`.
- `op = 1` → "Horarios Posibles": muestra un horario completo de la
  combinación actual, sin edición. Es la vista usada por `impcuadres`.
- `op = 2` → "Horas que no se Desean": marca celdas a evitar en `genera`.
  Persiste en `vaciohor`.

Teclas: `Tab`, flechas, `Espacio`, `Enter`, `Esc`.

### `impcuadres`
**Vista de horarios generados + impresión.**

- Llama a `genera` si aún no hay datos.
- Para cada `regcuadre`, reconstruye el horario con `tabla(1, …)`.
- `Enter` o `F10` → imprime a `LPT1`. Maneja "impresora no lista" con un
  bucle de reintento via `msgbox`.
- Layout de impresión: dibuja una grilla ASCII con caracteres semigráficos
  `┌─┐│└┘├─┤` (CP850).
- Atajos: flechas (siguiente/anterior), `Home`/`End` (primero/último),
  `F1` (ayuda contextual = tópico 19), `F5` (saltar a número específico).

### `genera`
**El corazón del programa.** Ver descripción del algoritmo en
[ARQUITECTURA.md → Algoritmo de generación](../ARQUITECTURA.md#algoritmo-de-generación-procedure-genera).

Resumen:

1. Selección de cursos vía `selectitem`.
2. Opcional: marcado de horas no deseadas vía `tabla(2)`.
3. Agrupa por curso en `curtemp[1..15, 1..25]` con contadores `max[i]`.
4. Bucle de contador multi-base sobre `top[]` (no recursivo).
5. Para cada combinación: construye `table[15,6]` y detecta `cruce`.
6. Escribe header (códigos) y luego las combinaciones sin cruce.
7. Reporta estadísticas en panel derecho + `msgbox`.

### `abrehor`
Abre/crea un `.HOR`. Si no especifica extensión, agrega `.HOR`. Valida que
el nombre no sea `CURSOS.DAT` y que no tenga espacios. Carga todos los
registros con `flag = '@'` y los ordena con `SortHor`. Antes de abrir el
nuevo, llama a `acthorario` para grabar el anterior.

### `abrecur`
Abre `CURSOS.DAT` (hardcoded). Si no existe, lo crea. Carga registros
activos en `cursos[]` y los ordena.

### `editcur(op : integer)`
CRUD sobre la base de datos de cursos:

- `op = 0` → adicionar (pide código, nombre, horas)
- `op = 1` → modificar (selecciona vía `selectitem`)
- `op = 2` → borrar
- `op = 3` → adicionar directamente con código ya validado (uso interno
  desde `edithor` cuando se referencia un curso inexistente)

Valida: nombre no vacío, `ht ∈ [2, 12]`, código único.

### `edithor(op : integer)`
CRUD sobre las secciones del archivo abierto:

- `op = 0` → adicionar (pide sección, código, profesor; luego `tabla(0)` para horas)
- `op = 1` → modificar profesor y/o re-marcar horas
- `op = 2` → borrar

Si el código no existe en la base, llama a `editcur(3)` para crearlo al vuelo.

### `infoarch`
Lista todas las secciones del archivo `.HOR` actual con su código, nombre
de curso, sección, profesor y horas. Paginación de 17 líneas con botón
"Pulse para Continuar…".

### `infototcur`
Lista todos los cursos en la base con código, nombre y horas. Misma
paginación.

### `infonom`
Refresca el panel "Archivo Abierto" con el nombre del `.HOR` actual.

### `about`
`msgbox` con créditos: autor, versión, copyright.

### `salir : boolean`
Confirmación con `msgbox`. Retorna `true` si el usuario confirma.

### `menu`
**Loop principal.** Inicializa `cuadres` (`gdh.tmp`), `posibles := false`,
y dibuja el menú. Recibe teclas y despacha a las 14 opciones. Al elegir
"Salir" y confirmar, llama a `clsout` (animación persianas) y `closegraph`.

## Estado mutable que cruza llamadas

`posit` (índice de la sección en edición) y `vaciohor` (matriz de horas no
deseadas) son **globales mutables** usados como canal lateral entre
`edithor`, `tabla` y `genera`. No hay encapsulación — típico de Pascal
estructurado.

## Limitaciones documentadas en el propio código

- `if alltrim(upper(out[1])) = 'CURSOS.DAT'` — bloquea ese nombre para
  evitar que el usuario sobrescriba la base de datos por accidente.
- El curso debe existir en la base **antes** de poder modificar la sección
  (se da la opción de adicionarlo al vuelo).
- Si `tothora < 2 × pares_marcados` en `tabla(0)`, no se puede grabar.
- La validación de cruces no considera **horas extra** ni laboratorios
  (limitación reconocida en `GDH.HLP` tópico 1).

## Cómo se relaciona con otros archivos

- Lee/escribe: `CURSOS.DAT`, `<nombre>.HOR`, `gdh.tmp`, imprime a `LPT1`.
- Lee: `GDH.HLP`.
- Llama a: [UHORA.PAS.md](UHORA.PAS.md), [UHORA2.PAS.md](UHORA2.PAS.md).
- **No llama** a [MOUSE.PAS.md](MOUSE.PAS.md) (aunque la unidad existe en
  [src/](../../src/)).
