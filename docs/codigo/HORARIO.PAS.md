# Documentación: `HORARIO.PAS`

> Programa principal **legacy** (v1.0). Coexiste con `HORA.PAS` en
> HORA11 y BETA96, pero `HORA.PAS` es la versión activa de v1.1.
>
> Archivo: [src/HORARIO.PAS](../../src/HORARIO.PAS) · 45 409 bytes · CP850 · CRLF

## Encabezado

```pascal
program Generador_de_Horarios;
uses crt, graph, uhora, uhora2;
```

Mismo `uses`, misma directiva de memoria `{$M 65520, 0, 655360}` que
`HORA.PAS`.

## Diferencias funcionales vs. `HORA.PAS`

`HORARIO.PAS` es el código del que evolucionó `HORA.PAS`. Las diferencias
clave (verificadas en los snapshots históricos) son:

### Estructura de `regcuadre`

| Versión | Campos |
|---|---|
| **HORABETA** (Ago 1995, v1.0 Beta) | `codigo: array[1..16] of string[5]; seccion: array[1..16] of string[4];` |
| **HORA10** y posteriores | `seccion: array[1..16] of string[5];` (códigos + secciones intercalados, header con `'@'` sentinel) |

`HORA.PAS` heredó la versión más reciente.

### Menú original (v1.0 Beta)

Según `CAMBIOS.TXT`, la v1.0 Beta tenía:

```pascal
{ HORABETA, versión 1.0 Beta }
const mn:array[1..14] of string=
  ('Nuevo Horario',
   'Cargar Horario de disco',
   'Cerrar Horario',
   'Adicionar/Editar/Ver Sección',
   'Borrar Curso de Sección',
   'Información del Horario',
   'Generar Horarios Posibles',
   'Ver/Imprimir Horarios',
   'Adicionar/Editar/Ver Curso',
   'Borrar Curso de la Base',
   'Información de los Cursos',
   'Ayuda',
   'Acerca de...',
   'Salir');
```

Que en v1.0 estable (HORA10 → HORA11) cambió a la lista actual de
`HORA.PAS` (ver [HORA.PAS.md](HORA.PAS.md)).

### Manejo de cursos en disco vs. RAM

En el código antiguo de [history/1995-08-HORABETA/HORARIO.PAS](../../history/1995-08-HORABETA/HORARIO.PAS)
se observa:

```pascal
var  cursos:   file of regcur;
     horarios: file of reghora;
```

Es decir, en la Beta los handles globales se llamaban `cursos` y
`horarios` directamente. En `HORA.PAS` v1.1 se renombraron a `filecur`,
`filehor` y `cuadres`, dejando los nombres `cursos[]` y `horarios[]` para
los arrays en RAM. Refactor de claridad.

## Por qué se conserva en `src/`

- Fidelidad histórica — es el código activo entre 1995 y comienzos de 1996.
- Compila con las mismas unidades `uhora` y `uhora2`.
- Sirve como punto de comparación con `HORA.PAS` para entender la
  evolución del diseño.

> **Para análisis evolutivo**, comparar:
> - [history/1995-08-HORABETA/HORARIO.PAS](../../history/1995-08-HORABETA/HORARIO.PAS) (Ago 1995)
> - [history/1995-09-HORA10/HORARIO.PAS](../../history/1995-09-HORA10/HORARIO.PAS) (Sep 1995)
> - [history/1996-02-BETA96/HORARIO.PAS](../../history/1996-02-BETA96/HORARIO.PAS) (Feb 1996)
> - [src/HORARIO.PAS](../../src/HORARIO.PAS) (Abr 1996, última versión)
