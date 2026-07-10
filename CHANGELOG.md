# Changelog

Todos los cambios notables de este proyecto se documentan en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/),
y este proyecto sigue [Versionado Semántico](https://semver.org/lang/es/).

## [Unreleased]

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

[Unreleased]: https://github.com/KamerrEzz/mi-terminal-config/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/KamerrEzz/mi-terminal-config/releases/tag/v1.0.0
