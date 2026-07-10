# --- Prompt (Oh My Posh, custom Tokyo Night theme with pnpm/node/git awareness) ---
oh-my-posh init pwsh --config (Join-Path $PSScriptRoot 'tokyonight-custom.omp.json') | Invoke-Expression

# --- Smart directory jumping ("z <part-of-folder-name>") ---
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# --- Listing with icons and git status (eza replaces ls) ---
if (Get-Command eza -ErrorAction SilentlyContinue) {
    Remove-Item alias:ls -Force -ErrorAction SilentlyContinue
    function ls { eza --icons --group-directories-first @args }
    function ll { eza -l --icons --git --group-directories-first @args }
    function la { eza -la --icons --git --group-directories-first @args }
    function lt { eza --tree --icons --level=2 @args }
}
Import-Module Terminal-Icons -ErrorAction SilentlyContinue

# --- Fuzzy search: Ctrl+T searches files, Ctrl+R searches history ---
if (Get-Module -ListAvailable PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# --- PSReadLine: predictive IntelliSense + Tokyo Night colors ---
try {
    Set-PSReadLineOption -PredictionSource History -ErrorAction Stop
    Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction Stop
} catch {
    # Console without VT support (remote session, redirected host, etc.) - skipped without breaking the profile
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

# --- Shortcuts (pnpm / git) - tweak to match your own package manager/workflow ---
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

# --- System banner when opening an interactive Windows Terminal tab ---
if ($env:WT_SESSION -and $Host.Name -eq 'ConsoleHost' -and (Get-Command fastfetch -ErrorAction SilentlyContinue)) {
    fastfetch --config (Join-Path $PSScriptRoot 'fastfetch.jsonc')
}
