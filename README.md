# mi-terminal-config

A Windows Terminal + PowerShell 7 setup built around the **Tokyo Night** theme,
an [Oh My Posh](https://ohmyposh.dev) prompt that's aware of your git/node/pnpm
context, a fastfetch system banner, fuzzy search, smart `cd`, and a proper
`ls` replacement — all wired up by a single script.

```
 ➜ mi-terminal-config ⚡ (main)  pnpm                          v22.10.0  19:47
▶ pnpm dev
  ⏱ 812ms                                                     v22.10.0  19:48
▶
```

## What's included

- **Tokyo Night** color scheme for Windows Terminal, 90% opacity + acrylic blur
- **Oh My Posh** prompt (`powershell/tokyonight-custom.omp.json`) showing:
  git branch/status, pnpm & Node versions (auto-detected per project),
  command execution time (when it's worth showing), clock, and an admin
  indicator — trimmed down to just the segments that matter, so it renders fast
- **fastfetch** banner (OS, CPU, RAM, disk, Node/pnpm versions) on every new tab
- **zoxide** — jump to any folder you've visited with `z <part-of-the-name>`
- **eza** — `ls` / `ll` / `la` / `lt` with icons and inline git status
- **fzf + PSFzf** — `Ctrl+T` fuzzy-finds files, `Ctrl+R` fuzzy-searches history
- **PSReadLine** predictive IntelliSense with a Tokyo Night color scheme
- **Quake mode** — press <kbd>Win</kbd>+<kbd>`</kbd> from *any* app to
  summon/hide Windows Terminal as a dropdown, system-wide
- Handy shortcuts: `pi`/`pd`/`pb`/`pr`/`px` for pnpm, `gs`/`ga`/`gc`/`gp`/`gl`/`gco` for git

## Requirements

- Windows 10 (2004+) or Windows 11
- [winget](https://aka.ms/getwinget) (ships with modern Windows; install from
  the Microsoft Store as "App Installer" if you don't have it)
- [Windows Terminal](https://aka.ms/terminal) installed from the Microsoft Store

## Install

```powershell
git clone https://github.com/KamerrEzz/mi-terminal-config.git
cd mi-terminal-config
./install.ps1
```

`install.ps1` is safe to re-run — it always backs up files before touching
them (`*.bak-<timestamp>`) and merges into your existing Windows Terminal
`settings.json` instead of replacing it, so your other profiles and tweaks
are left alone.

### What the installer actually does

1. Installs via `winget`: PowerShell 7, Oh My Posh, fastfetch, zoxide, eza, fzf
2. Installs the JetBrainsMono Nerd Font (needed for every icon you see above)
3. Installs the `Terminal-Icons` and `PSFzf` PowerShell modules
4. Copies the profile + theme + fastfetch config into your `$PROFILE` folder
   (backing up anything already there)
5. Merges the Tokyo Night scheme, font/opacity/cursor defaults, and the Quake
   mode keybinding into your Windows Terminal `settings.json`
6. Asks before changing your default profile — nothing happens silently

After it finishes: **close every Windows Terminal window and open a new one.**
Fonts and new profiles only apply to fresh windows.

If you'd rather do it by hand, `windows-terminal/settings.snippet.jsonc`
documents exactly what gets merged, and the files under `powershell/` are
plain profile/config files you can drop in yourself.

## Customizing

- Prompt segments/colors: edit `powershell/tokyonight-custom.omp.json` — see
  the [Oh My Posh docs](https://ohmyposh.dev/docs/configuration/overview)
- Startup banner: edit `powershell/fastfetch.jsonc` — see the
  [fastfetch config docs](https://github.com/fastfetch-cli/fastfetch/wiki/Configuration)
- Shortcuts/aliases: edit the bottom of `powershell/Microsoft.PowerShell_profile.ps1`

## Credits

This is a personal setup built on top of great open-source tools — full credit
to their authors:

- [Oh My Posh](https://ohmyposh.dev) by Jan De Dobbeleer
- [fastfetch](https://github.com/fastfetch-cli/fastfetch)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [eza](https://github.com/eza-community/eza)
- [fzf](https://github.com/junegunn/fzf) and [PSFzf](https://github.com/kelleyma49/PSFzf)
- [Terminal-Icons](https://github.com/devblackops/Terminal-Icons)
- [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme) color palette

## License

[MIT](LICENSE)
