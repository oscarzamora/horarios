# Reconstrucción 1.2 (final) con mouse — junio 1996

Esta es una reconstrucción del fuente perdido de junio 1996 del
**Generador de Horarios**, cuyo binario sí sobrevive en
[release/1996-06-FINAL/HORARIOS.EXE](../../release/1996-06-FINAL/HORARIOS.EXE)
(44 820 bytes, fechado `01-JUN-1996`).

> No es una decompilación. No se desensambló el `.EXE`. Es una
> **re-implementación del propio autor**, hecha en 2026, sobre el último
> fuente conservado (HORA11, 16-ABR-1996), integrando la unit
> `MOUSE.PAS` que estaba presente —sin uso— en todas las distribuciones
> de fuentes desde 1995.

## Versión de partida

| | |
|---|---|
| Fuente real | [history/1996-04-HORA11/](../../history/1996-04-HORA11/) (HORA11.ZIP, 51 257 bytes, 17-ABR-1996) |
| Fuente de la app | `HORA.PAS` 47 303 bytes, 16-ABR-1996 |
| Unit gráfica | `UHORA.PAS` 17 675 bytes, 06-SEP-1995 |
| Unit texto | `UHORA2.PAS` 2 077 bytes, 15-ABR-1996 |
| Unit mouse | `MOUSE.PAS` 5 884 bytes, **31-MAY-1994** (anterior al proyecto) |

> Nota: a la fecha de este commit, `history/1996-04-HORA11/` aún no fue
> creada como carpeta histórica formal. El fuente HORA11 está disponible
> en el ZIP archivado `OneDrive/_Archived_/DOS Applications/Projects/Turbo Pascal/HORA11.ZIP`
> y, mientras tanto, sus archivos están copiados en `src/` del repo.

## Qué cambió respecto a 1.1 (HORA11)

### Archivos NUEVOS — ninguno
Todo se hizo sobre los archivos existentes.

### Archivos COPIADOS sin tocar
- `MOUSE.PAS` — unit del autor de 1994, lista para usar; nunca se modifica
- `UHORA2.PAS` — utilidades de texto
- `GDH.HLP`, `GEN.HOR`, `CURSOS.DAT`, `PRUEBA.HOR`, `PRUEBA2.HOR`, `CUR.DAT`

### Archivos MODIFICADOS

#### `UHORA.PAS` (17 675 → 27 199 bytes)

1. **Interface** — agrega `mouse` al `uses`, expone:
   ```pascal
   var       hasMouse:boolean;
   procedure initMouseSupport;
   procedure showMouse;
   procedure hideMouse;
   function  mouseHit(x1,y1,x2,y2:integer):boolean;
   ```
2. **Implementation** — añade al inicio las 4 procs/funcs anteriores.
   - `initMouseSupport` hace `MouseExist` + `LimitMouse` + `MouseOn`.
   - `mouseHit` es un hit-test no bloqueante con espera al *unclick*
     para que el mismo click no se procese dos veces en bucles
     sucesivos.
3. **`msgbox`** — antes del `key:=readkey;` ahora hay un loop *polling*
   que reacciona tanto a teclado como a click en los botones `OK` y
   `Cancelar`. El comportamiento por teclado es **idéntico** al de 1.1.
4. **`gettext`** — ambos bucles del formulario (edición de campo y
   selección final de botón) pasan a *polling*. Soporta:
   - click directo sobre **cualquier campo** salta el cursor a ese
     campo, comiteando el campo actual (equivalente a sucesivos `TAB`);
   - click en `OK` comitea y sale como `ENTER`;
   - click en `Cancelar` sale como `ESC`.
5. **`selectitem`** — mismo patrón: click en `OK`, `Cancelar`,
   **directamente sobre un ítem visible** de la lista (15 visibles a
   la vez) y **scrollbar completo**:
   - flecha ▲ arriba ≡ cursor arriba;
   - flecha ▼ abajo ≡ cursor abajo;
   - click en cualquier punto del track salta proporcionalmente a esa
     posición de la lista.

   Para selección única (`maxindex=1`) un click en un ítem confirma;
   para selección múltiple (`maxindex>1`) un click hace toggle, igual
   que `SPACE`.

#### `HORA.PAS` (47 303 → 52 149 bytes)

1. **Header** — cambia a `versión 1.2` con nota explícita de
   reconstrucción.
2. **`uses`** — añade `mouse` (necesario para llamar a `MouseDown`,
   `Mouseln`, `MouseX` y `MouseY` directamente desde `HORA.PAS`).
3. **`procedure menu`** — el `key:=readkey;` del menú principal pasa a
   ser un loop *polling*: tecla **o** click sobre uno de los 14 botones
   del menú principal. Al hacer click sobre un botón es equivalente a
   navegar hasta él y presionar `ENTER`.
4. **`procedure tabla`** — la grilla 15 × 6 (LUNES…SABADO ×
   07:00–21:00) ahora responde a clicks: cada click en una celda
   mueve el cursor a esa celda y la marca/desmarca, equivalente a
   `flechas` + `SPACE`. Funciona en `op=0` (definir horas) y `op=2`
   (horas no deseadas).
5. **`procedure impcuadres`** — antes solo respondía a teclas
   (`PgUp/PgDn/Home/End/Enter/Esc`) **sin botones visibles**. Ahora se
   dibuja una barra de navegación bajo el horario:
   `[<<] [<] [>] [>>] [Imprimir] [Salir]`, equivalentes a
   `Home`, `PgUp`, `PgDn`, `End`, `Enter` y `Esc` respectivamente.
   La barra solo se dibuja si hay mouse detectado.
6. **`procedure InicGraficos`** — llama a `initMouseSupport` justo
   después de `Initgraph` y desactiva el mouse antes de `closegraph`.
7. **Banner final** — cambia `'Generador de Horarios v1.1. XX/XX/96'`
   por `'v1.2. 01/06/96'` para reflejar la fecha del binario que esta
   reconstrucción intenta emular.

## Cobertura del mouse en la UI

Todos los puntos de espera por teclado del programa quedaron
integrados con mouse, manteniendo el comportamiento por teclado
intacto:

| Pantalla | Acción con mouse |
|---|---|
| Menú principal (14 botones) | Click en botón = navegar + `ENTER` |
| `msgbox` (diálogo OK/Cancelar) | Click en `OK` o `Cancelar` |
| `selectitem` (lista seleccionable) | Click en ítem, en `OK`, en `Cancelar`, en flechas ▲ ▼ del scrollbar y en el track del scrollbar |
| `gettext` (formulario de campos) | Click en cualquier campo, en `OK`, en `Cancelar` |
| `tabla` (grilla 15 × 6 de horas) | Click en cualquier celda ≡ mover cursor + `SPACE` |
| `impcuadres` (visor de horarios) | Botones `[<<] [<] [>] [>>] [Imprimir] [Salir]` |

## Supuestos asumidos en la reconstrucción

1. **El mouse se integró**, sí, en algún momento entre HORA11 (abril)
   y el binario FINAL (junio). Evidencia indirecta:
   - `MOUSE.PAS` está en TODAS las distribuciones de fuentes desde
     septiembre 1995 — el autor la mantuvo presente durante 9 meses.
   - El binario final (`HORARIOS.EXE`, 44 820 bytes) es ~3 KB más
     grande que el de HORA10 (39 804 bytes); cabe perfectamente un
     `MOUSE.TPU` compilado más las llamadas integradas.
   - Documentos del autor referenciaban "manejo con mouse" como
     mejora final.
2. **El estilo de integración** se asume *defensivo y opcional*:
   `hasMouse` se chequea siempre, todo sigue funcionando con teclado
   si no hay mouse o controlador. Es el patrón idiomático del autor
   en otras unidades (graceful degradation).
3. **El polling es síncrono** (`keypressed` + `MouseDown` en loop),
   no event-driven. Es lo único factible en Turbo Pascal real-mode
   sin hooks de INT 33h adicionales — y MOUSE.PAS no expone los
   handlers `subfunction 0Ch` necesarios para un modelo event-driven.

## Cómo compilar (referencial)

Esta reconstrucción está pensada para Turbo Pascal 7.0 sobre DOS
(o DOSBox + TP7). Pasos:

```
TPC HORA.PAS
```

El compilador genera automáticamente `UHORA2.TPU`, `UHORA.TPU` y
`MOUSE.TPU` en ese orden y enlaza el `HORARIOS.EXE`. Requiere
`EGAVGA.BGI` y `LITT.CHR` en el mismo directorio en runtime, igual
que el original. El programa intenta cargar `BGI` desde
`c:\util\leng\tpascal\bgi` por defecto (heredado del original);
ajustar esa ruta a la propia instalación.

## Falsabilidad

Si en el futuro aparece el fuente real de junio 1996 (en otro backup,
disquete o ZIP) y difiere de esta reconstrucción, lo correcto es:

1. Importar el fuente real como `history/1996-06-FINAL-source/`.
2. Mantener esta carpeta como referencia histórica de la
   reconstrucción.
3. Documentar el diff entre reconstrucción y original para aprender
   qué supuestos fallaron.
