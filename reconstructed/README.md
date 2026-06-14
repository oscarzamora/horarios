# `reconstructed/` — Reconstrucciones por fuente perdida

Esta carpeta contiene **reconstrucciones modernas** del autor sobre puntos
del proyecto cuyo código fuente original **se perdió** y del que sólo
sobrevive el binario distribuido. No es decompilación, no es ingeniería
inversa de bytes y no pretende reproducir el `.EXE` bit a bit. Es una
**re-implementación honesta** a partir de:

- el fuente disponible más cercano en el tiempo (`history/`),
- los assets que sí se conservaron (gráficos `.BGI`, `.CHR`, `.HLP`),
- el binario final como referencia de comportamiento observable,
- y el estilo y convenciones del propio autor en los fuentes archivados.

Cada subcarpeta se documenta a sí misma con un `RECONSTRUCTION-NOTES.md`
que detalla:

- de qué versión real (en `history/`) parte la reconstrucción,
- qué cambios mínimos se aplicaron,
- qué supuestos se asumieron y por qué,
- qué quedó deliberadamente fuera del alcance.

> **Importante:** cada archivo modificado lleva en su cabecera una nota
> visible de reconstrucción para que nadie lo confunda con el original.
> Los archivos no modificados (binarios `.BGI/.CHR/.HLP/.HOR/.DAT` y
> sources que no se tocaron, como `MOUSE.PAS` y `UHORA2.PAS`) son copias
> exactas de la versión de partida y no llevan nota.

## Reconstrucciones publicadas

| Carpeta | Parte de | Reconstruye | Cambio principal |
|---|---|---|---|
| [1996-06-FINAL-with-mouse/](1996-06-FINAL-with-mouse/) | `history/1996-04-HORA11/` (HORA11.ZIP, 16-ABR-1996) | El fuente perdido de junio 1996 cuyo binario está en [release/1996-06-FINAL/](../release/1996-06-FINAL/) | Integra `MOUSE.PAS` (presente y sin usar desde 1995) en el menú principal y en los diálogos `msgbox` / `selectitem` |
