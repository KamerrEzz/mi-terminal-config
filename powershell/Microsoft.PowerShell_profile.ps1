# --- Prompt (Oh My Posh, tema Tokyo Night custom con soporte pnpm/node/git) ---
oh-my-posh init pwsh --config (Join-Path $PSScriptRoot 'tokyonight-custom.omp.json') | Invoke-Expression

# --- Navegación inteligente entre carpetas (zoxide: "z <parte-del-nombre>") ---
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# --- Listado con iconos y estado de git (eza reemplaza a ls) ---
if (Get-Command eza -ErrorAction SilentlyContinue) {
    Remove-Item alias:ls -Force -ErrorAction SilentlyContinue
    function ls { eza --icons --group-directories-first @args }
    function ll { eza -l --icons --git --group-directories-first @args }
    function la { eza -la --icons --git --group-directories-first @args }
    function lt { eza --tree --icons --level=2 @args }
}
Import-Module Terminal-Icons -ErrorAction SilentlyContinue

# --- Búsqueda difusa: Ctrl+T busca archivos, Ctrl+R busca en el historial ---
if (Get-Module -ListAvailable PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# --- Carapace: autocompletado real (subcomandos y flags, no solo archivos) para git/gh/docker/pnpm y cientos más ---
if (Get-Command carapace -ErrorAction SilentlyContinue) {
    carapace _carapace | Out-String | Invoke-Expression
}

# --- PSReadLine: autocompletado predictivo + colores a juego con Tokyo Night ---
try {
    Set-PSReadLineOption -PredictionSource History -ErrorAction Stop
    Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction Stop
} catch {
    # Consola sin soporte VT (sesión remota, host redirigido, etc.) - se omite sin romper el profile
}
Set-PSReadLineOption -Colors @{
    Command   = "#7AA2F7"
    Parameter = "#BB9AF7"
    String    = "#9ECE6A"
    Operator  = "#89DDFF"
    Variable  = "#C0CAF5"
    Comment   = "#565F89"
    Keyword   = "#F7768E"
}
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# --- Atajos (pnpm / git) - adaptalos a tu propio gestor de paquetes/flujo de trabajo ---
function pi { pnpm install @args }
function pd { pnpm dev @args }
function pb { pnpm build @args }
function pr { pnpm run @args }
function px { pnpm dlx @args }

function gs { git status @args }
function ga { git add @args }
function gc { git commit @args }
function gp { git push @args }
function gl { git log --oneline --graph --decorate @args }
function gco { git checkout @args }

# --- Banner de sistema al abrir una terminal interactiva en Windows Terminal ---
if ($env:WT_SESSION -and $Host.Name -eq 'ConsoleHost' -and (Get-Command fastfetch -ErrorAction SilentlyContinue)) {
    fastfetch --config (Join-Path $PSScriptRoot 'fastfetch.jsonc')
}
