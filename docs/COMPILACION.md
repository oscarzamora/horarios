# Compilación y Ejecución

> El programa fue escrito para **Turbo Pascal 6.0 / 7.0 en MS-DOS** con modo
> gráfico VGA vía BGI. Para correrlo hoy necesitas o bien un compilador
> Pascal que entienda el dialecto Turbo Pascal *real-mode*, o un emulador
> que provea el entorno DOS completo.

## Opción A · Turbo Pascal 7 + DOSBox (recomendada, máxima fidelidad)

Esta es la forma más fiel al entorno original. El programa correrá
exactamente igual que en 1996.

### Requisitos

- [**DOSBox-X**](https://dosbox-x.com/) o [DOSBox](https://www.dosbox.com/)
- **Turbo Pascal 7.0** (Borland lo liberó como
  [Antique Software](https://winworldpc.com/product/turbo-pascal/7x))
- El archivo `EGAVGA.BGI` y `egavga.bgi` (vienen con TP7 en `BGI/`)

### Pasos

1. Instala TP7 en DOSBox montando una carpeta como `C:`:

   ```
   mount c c:\TP7
   c:
   cd bp\bin
   bp.exe
   ```

2. Monta este repositorio como `D:` (por ejemplo):

   ```
   mount d <ruta-local-al-repo>\src
   ```

3. Dentro del IDE de Turbo Pascal, abre `D:\HORA.PAS`.
4. Configura el path de unidades (Options → Directories) para que vea
   `EGAVGA.BGI`. Lo más simple: copia `EGAVGA.BGI` junto a `HORA.PAS`.
5. Compila con **Alt+F9** o ejecuta con **Ctrl+F9**.

> **Importante:** el programa hace `assign(filecur, 'Cursos.Dat')` con ruta
> relativa. Asegúrate de que el directorio de trabajo de DOSBox sea
> [src/](../src/) cuando ejecutes — sino no encontrará `CURSOS.DAT`,
> `GDH.HLP` ni los `*.HOR`.

### Compilar la versión legacy (HORARIO.PAS)

```
bp.exe HORARIO.PAS
```

Misma estructura — usa las mismas unidades `uhora` y `uhora2`.

## Opción B · Free Pascal (FPC) con modo Turbo Pascal

Free Pascal puede compilar **gran parte** del código en modo `-Mtp`
(Turbo Pascal mode), pero hay limitaciones:

- ✅ `uses crt, graph` — FPC los reimplementa para Win32/Linux.
- ✅ `unit uhora2` (texto puro) — compila sin cambios.
- ⚠️ `unit uhora` (BGI) — la unidad `graph` de FPC en Windows funciona pero
  usa una ventana SDL/GDI; los modos VGA exactos pueden diferir.
- ❌ `unit Mouse` — usa `intr(51, regs)` (interrupción real-mode 33h del BIOS).
  **No funciona fuera de DOS.** Requeriría reescritura para SDL/Win32.
- ⚠️ `{$M ..., ..., 655360}` — directiva de memoria DOS, FPC la ignora.
- ⚠️ Acceso a `LPT1` en `impcuadres` — en FPC moderno no escribe a impresora
  física; reescribir como `assign(lst, 'salida.txt')` para pruebas.

### Compilar con FPC

```powershell
# Instalar Free Pascal: https://www.freepascal.org/download.html
fpc -Mtp -Sa -O2 src/HORA.PAS
```

Para que funcione fuera de DOS, hay que comentar `uses mouse` (no está en
el `uses` actual, así que no es problema) y posiblemente adaptar el inicio
de modo gráfico (`initgraph`).

### Compilar en modo DOS con FPC + go32v2

Si quieres un `.EXE` que corra en DOSBox como el original, sin necesitar
TP7:

```powershell
fpc -Mtp -Tgo32v2 -O2 src/HORA.PAS
```

Esto produce un ejecutable DOS de 32 bits con DPMI, que sí soporta `intr`
y el modelo de memoria original.

## Opción C · Solo leer / explorar el código

Si solo quieres entender el código sin compilar, **basta con VS Code**:

1. Instala la extensión **Pascal** (recomendada en
   [.vscode/extensions.json](../.vscode/extensions.json)).
2. La configuración en [.vscode/settings.json](../.vscode/settings.json) ya
   asocia `.PAS` al lenguaje Pascal con encoding **CP850**.
3. Abre cualquier `.PAS` — los acentos y `ñ` deben verse correctamente.

Para los `.HOR` y `.DAT` (binarios), usa la extensión
**Hex Editor** o cualquier visor hex; el layout está documentado en
[FORMATO-DATOS.md](FORMATO-DATOS.md).

## Cómo se ve si compila y corre

```
┌── Generador de Horarios ─────────────────────────────────┐
│ ┌──────────────────┐ ┌─ Archivo Abierto ────────────────┐│
│ │   Menú General   │ │ Archivo en uso: GEN.HOR          ││
│ │                  │ └──────────────────────────────────┘│
│ │ Nombre del…      │ ┌─ Información ────────────────────┐│
│ │ Adicionar Curso  │ │                                  ││
│ │ Modificar/Verif… │ │  (panel dinámico)                ││
│ │ Borrar Curso     │ │                                  ││
│ │ Información del… │ │                                  ││
│ │ Generar Horarios │ │                                  ││
│ │ Ver/Imprimir     │ │                                  ││
│ │ Adicionar a Base │ │                                  ││
│ │ Modificar de Base│ │                                  ││
│ │ Borrar de Base   │ │                                  ││
│ │ Cursos en BD     │ │                                  ││
│ │ Ayuda            │ │                                  ││
│ │ Acerca de…       │ │                                  ││
│ │ Salir            │ │                                  ││
│ └──────────────────┘ └──────────────────────────────────┘│
└──────────────────────────────────────────────────────────┘
```

Resolución 640×480 píxeles, paleta 16 colores VGA. Navegación únicamente
con **teclado** (flechas + Enter + Esc + Tab + F1 + F5).
