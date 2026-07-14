# mi-terminal-config

Una configuración de Windows Terminal + PowerShell 7 basada en el tema
**Tokyo Night**, con un prompt de [Oh My Posh](https://ohmyposh.dev) que
reconoce tu contexto de git/node/pnpm, un banner de sistema con fastfetch,
búsqueda difusa, navegación inteligente entre carpetas, y un reemplazo
como la gente para `ls` — todo instalado con un solo script.

![](https://raw.githubusercontent.com/KamerrEzz/mi-terminal-config/refs/heads/main/CAPTURE.png)

## Qué incluye

- **Tokyo Night**: esquema de color para Windows Terminal, 90% de opacidad + acrylic
- **Oh My Posh** (`powershell/tokyonight-custom.omp.json`) mostrando:
  rama y estado de git, versiones de pnpm y Node (detectadas por proyecto),
  tiempo de ejecución del comando (cuando vale la pena mostrarlo), hora, e
  indicador de admin — recortado a solo los segmentos que importan, para que
  renderice rápido
- **fastfetch**: banner de sistema (OS, CPU, RAM, disco, versiones de Node/pnpm)
  en cada pestaña nueva
- **zoxide**: saltá a cualquier carpeta que ya visitaste con `z <parte-del-nombre>`
- **eza**: reemplaza `ls` con íconos y estado de git — cuatro variantes según
  cuánto detalle necesites (tabla abajo)
- **fzf + PSFzf**: `Ctrl+T` busca archivos, `Ctrl+R` busca en el historial, ambos
  con búsqueda difusa
- **PSReadLine** con autocompletado predictivo y colores Tokyo Night
- **Modo Quake**: apretá <kbd>Win</kbd>+<kbd>`</kbd> desde *cualquier* aplicación
  para invocar/ocultar Windows Terminal como un dropdown, en todo el sistema
- Atajos cortos para pnpm y git — qué hace cada uno, en la tabla de abajo

## Referencia rápida de comandos

No hace falta memorizar nada de esto para usar el setup — son atajos opcionales
que ahorran tipeo. Esta tabla es para cuando te cruces con uno y no te acuerdes
qué hace.

### Listar archivos (eza reemplaza a `ls`)

| Comando | Qué muestra |
|---|---|
| `ls` | Listado simple, con íconos y carpetas primero |
| `ll` | Listado **largo**: permisos, tamaño, fecha y estado de git por archivo |
| `la` | Como `ll`, pero **incluye los archivos ocultos** (los que empiezan con `.`) |
| `lt` | **Árbol** de carpetas (2 niveles), en vez de una lista plana |

### Atajos de pnpm

| Atajo | Equivale a | Qué hace |
|---|---|---|
| `pi` | `pnpm install` | Instala las dependencias del proyecto |
| `pd` | `pnpm dev` | Levanta el entorno de desarrollo |
| `pb` | `pnpm build` | Genera la build de producción |
| `pr` | `pnpm run` | Corre un script del `package.json` (ej: `pr test`) |
| `px` | `pnpm dlx` | Ejecuta un paquete sin instalarlo, como `npx` |

### Atajos de git

| Atajo | Equivale a | Qué hace |
|---|---|---|
| `gs` | `git status` | Muestra qué archivos cambiaron y cuáles están en staging |
| `ga` | `git add` | Agrega archivos al staging (ej: `ga .` para todos) |
| `gc` | `git commit` | Crea un commit con los cambios en staging |
| `gp` | `git push` | Sube tus commits al repositorio remoto |
| `gl` | `git log --oneline --graph --decorate` | Historial compacto, con gráfico de ramas |
| `gco` | `git checkout` | Cambia de rama o descarta cambios en un archivo |

¿Preferís tus propios alias o no usás pnpm? Están definidos al final de
`powershell/Microsoft.PowerShell_profile.ps1` — borralos o cambialos como
quieras, no dependen de nada más del setup.

## Requisitos

- Windows 10 (2004+) o Windows 11
- [winget](https://aka.ms/getwinget) (viene con Windows moderno; si no lo tenés,
  instalá "App Installer" desde la Microsoft Store)
- [Windows Terminal](https://aka.ms/terminal) instalado desde la Microsoft Store

## Instalación

```powershell
git clone https://github.com/KamerrEzz/mi-terminal-config.git
cd mi-terminal-config
./install.ps1
```

`install.ps1` se puede correr las veces que quieras sin miedo — siempre hace
una copia de seguridad antes de tocar tus archivos (`*.bak-<timestamp>`) y
mezcla los cambios con tu `settings.json` de Windows Terminal en vez de
reemplazarlo, así que tus otros perfiles y ajustes quedan intactos.

### Qué hace el instalador exactamente

1. Instala con `winget`: PowerShell 7, Oh My Posh, fastfetch, zoxide, eza, fzf
2. Instala la Nerd Font JetBrainsMono (necesaria para que se vean todos los
   íconos de arriba)
3. Instala los módulos de PowerShell `Terminal-Icons` y `PSFzf`
4. Copia el profile, el tema y la config de fastfetch a tu carpeta `$PROFILE`
   (haciendo backup de lo que ya tengas ahí)
5. Mezcla el esquema Tokyo Night, la fuente/opacidad/cursor y el atajo del
   modo Quake dentro de tu `settings.json` de Windows Terminal
6. Te pregunta antes de cambiar tu perfil por defecto — nada pasa en silencio

Cuando termine: **cerrá todas las ventanas de Windows Terminal y abrí una
nueva.** Las fuentes y los perfiles nuevos solo aplican en ventanas nuevas.

Si preferís hacerlo a mano, `windows-terminal/settings.snippet.jsonc`
documenta exactamente qué se mezcla, y los archivos dentro de `powershell/`
son configs comunes que podés copiar vos mismo.

## Personalización

- Segmentos/colores del prompt: editá `powershell/tokyonight-custom.omp.json` —
  mirá la [documentación de Oh My Posh](https://ohmyposh.dev/docs/configuration/overview)
- Banner de inicio: editá `powershell/fastfetch.jsonc` — mirá la
  [documentación de fastfetch](https://github.com/fastfetch-cli/fastfetch/wiki/Configuration)
- Atajos/alias: editá el final de `powershell/Microsoft.PowerShell_profile.ps1`

## Créditos

Esta es una configuración personal construida sobre grandes herramientas
open-source — todo el crédito a sus autores:

- [Oh My Posh](https://ohmyposh.dev) por Jan De Dobbeleer
- [fastfetch](https://github.com/fastfetch-cli/fastfetch)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [eza](https://github.com/eza-community/eza)
- [fzf](https://github.com/junegunn/fzf) y [PSFzf](https://github.com/kelleyma49/PSFzf)
- [Terminal-Icons](https://github.com/devblackops/Terminal-Icons)
- Paleta de colores [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme)

## Licencia

[MIT](LICENSE)
