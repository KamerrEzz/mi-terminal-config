# Changelog

Todos los cambios notables de este proyecto se documentan en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/),
y este proyecto sigue [Versionado Semántico](https://semver.org/lang/es/).

## [Unreleased]

## [1.0.3] - 2026-07-10

### Corregido
- `install.ps1` desbloquea todo el contenido del repo (Mark of the Web) antes de copiar el profile de PowerShell y los archivos de tema. Antes, si el repo se había descargado como ZIP desde GitHub, el profile copiado quedaba marcado como "descargado de internet" y pwsh lo bloqueaba con "no está firmado digitalmente" al abrir una sesión nueva

## [1.0.2] - 2026-07-10

### Corregido
- `install.ps1` ya no falla al mezclar `settings.json` de Windows Terminal cuando ese archivo ya trae `schemes` o `keybindings` como array vacío (el chequeo evaluaba el valor en vez de la existencia de la propiedad, y PowerShell trata un array vacío como "falso")

## [1.0.1] - 2026-07-10

### Corregido
- `install.ps1` ahora funciona con el PowerShellGet 1.0.0.1 que trae Windows PowerShell 5.1 por defecto (antes fallaba con "no se encuentra el parámetro AcceptLicense" y se colgaba pidiendo confirmación manual del proveedor NuGet)

### Documentación
- Agregada tabla de referencia con los atajos de eza, pnpm y git

## [1.0.0] - 2026-07-09

### Agregado
- Setup completo de Windows Terminal: esquema de color Tokyo Night, transparencia acrylic, fuente Nerd Font JetBrainsMono
- Prompt de Oh My Posh con segmentos conscientes de git, Node y pnpm, tiempo de ejecución de comandos e indicador de administrador
- Banner de sistema con fastfetch mostrando el logo de marca Zeew en cada pestaña nueva
- Navegación inteligente entre carpetas con zoxide
- Reemplazo de `ls` con íconos y estado de git vía eza (`ls`/`ll`/`la`/`lt`)
- Búsqueda difusa de archivos e historial con fzf + PSFzf (Ctrl+T / Ctrl+R)
- Modo Quake de Windows Terminal (Win+`) para invocar la terminal desde cualquier aplicación
- Atajos de pnpm y git (`pi`/`pd`/`pb`/`pr`/`px`, `gs`/`ga`/`gc`/`gp`/`gl`/`gco`)
- Instalador automático (`install.ps1`) idempotente, con respaldo de archivos existentes y mezcla no destructiva del `settings.json` de Windows Terminal

### Documentación
- Todo el repositorio traducido al español para la comunidad hispana

[Unreleased]: https://github.com/KamerrEzz/mi-terminal-config/compare/v1.0.3...HEAD
[1.0.3]: https://github.com/KamerrEzz/mi-terminal-config/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/KamerrEzz/mi-terminal-config/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/KamerrEzz/mi-terminal-config/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/KamerrEzz/mi-terminal-config/releases/tag/v1.0.0
