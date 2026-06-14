# Release 1996-06-FINAL · Generador de Horarios v1.1 (con mouse)

> **Fin de creación: 1 de junio de 1996** (según `Readme.txt` original).
>
> Esta es la **versión final efectivamente distribuida** del programa. Es la
> que reemplazó a HORA11 (preservada en [../../src/](../../src/)) e incorpora
> el soporte de **mouse vía INT 33h** que estaba planeado desde BETA96.

## El gap importante

El **código fuente Pascal** que generó este EXE **NO se preservó**. Solo
sobreviven:

- `HORARIOS.EXE` compilado (44 820 bytes, 1-jun-1996)
- `GDH.HLP` actualizado (18 220 bytes, 1-jun-1996)
- Drivers BGI necesarios (`EGAVGA.BGI`, `LITT.CHR`)
- `Readme.txt` con instrucciones de instalación (versión 1999)

El último source preservado es **HORA11 (16-abr-1996)** en [../../src/](../../src/),
que es ~6 semanas anterior y todavía no tiene la integración de mouse en
`HORA.PAS` (la unidad `MOUSE.PAS` ya estaba presente pero sin enlazar).

## Evidencia técnica del soporte de mouse

| Verificación | Resultado |
|---|---|
| Opcode `INT 33h` (`CD 33`) en `HORARIOS.EXE` | ✅ presente |
| Tópico "Usando el Mouse" en `GDH.HLP` | ✅ presente |
| Menciones de "mouse" en el manual | 7 |
| Menciones de "click" en el manual | 14 |
| Menciones de "botón" en el manual | 8 |

## Diff de tópicos del manual: HORA11 (abr) → v1.1 FINAL (jun)

**Tópicos nuevos en jun-1996** (13):

- ✨ **Usando el Mouse** ← novedad principal
- Crear/Usar Archivo
- Adicionar Sección · Modificar/Verificar Sección · Eliminar Sección
- Información de Secciones
- Eliminar Curso de la Base
- Ventana Ver/Imprimir Horarios
- Def. de Horas de un Curso
- Def. de Horas no Deseadas
- Por qué la mala impresión · se demora al generar · se cuelga el programa

**Tópicos renombrados o eliminados** (11): el menú cambió "Curso" →
"Sección" en varias opciones, y se reorganizó la sección de ayuda
contextual.

## Contenido de este directorio

| Archivo | Tamaño | Fecha | Notas |
|---|---|---|---|
| `HORARIOS.EXE` | 44 820 | 1-jun-1996 | Ejecutable DOS con mouse integrado |
| `GDH.HLP` | 18 220 | 1-jun-1996 | Manual del programa (24 tópicos, +21% vs HORA11) |
| `EGAVGA.BGI` | 5 527 | 1-jun-1996 | Driver gráfico BGI VGA/EGA (estándar Turbo Pascal) |
| `LITT.CHR` | 5 131 | 1-jun-1996 | Font vectorial "Little" del BGI |
| `CURSOS.DAT` | 2 156 | _saneado_ | Base de cursos (datos sintéticos por privacidad) |
| `GEN.HOR` | _saneado_ | _saneado_ | Horario de prueba (datos sintéticos por privacidad) |
| `Readme.txt` | 526 | 1999 | Instrucciones originales de instalación |

Ver [../../docs/SANEAMIENTO.md](../../docs/SANEAMIENTO.md) para el detalle del
saneamiento de `.DAT` y `.HOR`.

## Cómo ejecutar este release

Necesitas un emulador de MS-DOS:

```
# DOSBox / DOSBox-X
mount c <ruta-local>/release/1996-06-FINAL
c:
horarios.exe
```

Requisitos originales declarados en el manual:

- Procesador 286 o superior
- Monitor + tarjeta gráfica VGA estándar
- Recomendado: cache de disco SMARTDRV (acceso constante a disco)
- Mouse compatible Microsoft (driver MOUSE.COM cargado)

## Notas sobre el `Readme.txt` original

El `Readme.txt` conserva los datos de contacto del autor en 1999:

- `E-mail: zamorin@altavista.net` — AltaVista cerró en 2013, cuenta extinta
- `Web-site: http://come.to/linkszamorin` — servicio de redirección de los 90s, ya no existe

Se preserva tal cual como **artefacto histórico** que muestra cómo se
distribuía software personal en la web de finales de los 90s (READMEs en
texto plano, emails de servicios webmail, dominios cortos por redirectores).

Para contacto actual del autor:
[ozamora.com](https://ozamora.com) · [@oscarzamora](https://github.com/oscarzamora)
