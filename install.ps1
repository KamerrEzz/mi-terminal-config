#Requires -Version 5.1
<#
.SYNOPSIS
    Installs and wires up this repo's Windows Terminal + PowerShell 7 setup:
    Tokyo Night theme, Oh My Posh prompt (with pnpm/node/git segments), fastfetch
    banner, zoxide, eza, fzf, Terminal-Icons and a Quake-mode keybinding.

.DESCRIPTION
    Safe to re-run. Existing files are backed up before being touched, and the
    Windows Terminal settings.json is merged (not replaced) so your other
    profiles and tweaks are left alone.
#>

$ErrorActionPreference = 'Stop'
$repoRoot = $PSScriptRoot

function Write-Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "    OK  $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "    !!  $msg" -ForegroundColor Yellow }

# ---------------------------------------------------------------------------
Write-Step "Checking prerequisites"
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget is not available. Install 'App Installer' from the Microsoft Store first: https://aka.ms/getwinget"
}
Write-Ok "winget found"

# ---------------------------------------------------------------------------
Write-Step "Installing packages via winget (skips anything already installed)"
$packages = @(
    'Microsoft.PowerShell',
    'JanDeDobbeleer.OhMyPosh',
    'Fastfetch-cli.Fastfetch',
    'ajeetdsouza.zoxide',
    'eza-community.eza',
    'junegunn.fzf'
)
foreach ($id in $packages) {
    Write-Host "    installing $id ..."
    winget install -e --id $id --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
}
Write-Ok "Package installs done"

# Refresh PATH in this session so freshly installed binaries resolve below
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
            [System.Environment]::GetEnvironmentVariable('Path', 'User')

# ---------------------------------------------------------------------------
Write-Step "Installing JetBrainsMono Nerd Font"
Add-Type -AssemblyName System.Drawing
$fontAlreadyInstalled = [bool](
    (New-Object System.Drawing.Text.InstalledFontCollection).Families |
    Where-Object { $_.Name -like 'JetBrainsMono NF*' }
)
if ($fontAlreadyInstalled) {
    Write-Ok "Font already installed"
} elseif (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    # `oh-my-posh font install` can hang after finishing in non-interactive/
    # non-console hosts instead of returning control - never let it block the
    # rest of the install.
    $job = Start-Job -ScriptBlock { oh-my-posh font install JetBrainsMono }
    if (Wait-Job $job -Timeout 60) {
        Receive-Job $job -ErrorAction SilentlyContinue | Out-Null
        Write-Ok "Font installed"
    } else {
        Write-Warn "Font install is taking too long - install it yourself with: oh-my-posh font install JetBrainsMono"
    }
    Remove-Job $job -Force -ErrorAction SilentlyContinue
} else {
    Write-Warn "oh-my-posh not found on PATH yet - re-run this script after restarting your terminal to install the font"
}

# ---------------------------------------------------------------------------
Write-Step "Installing PowerShell modules"

# Make sure NuGet + PSGallery trust are in place so Install-Module never
# stops to ask an interactive question below.
if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
}
if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') {
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}

foreach ($mod in @('Terminal-Icons', 'PSFzf')) {
    if (-not (Get-Module -ListAvailable -Name $mod)) {
        Install-Module -Name $mod -Repository PSGallery -Scope CurrentUser -Force -AcceptLicense -AllowClobber
    }
    Write-Ok "$mod ready"
}

# ---------------------------------------------------------------------------
Write-Step "Deploying PowerShell profile"
if (-not (Get-Command pwsh -ErrorAction SilentlyContinue)) {
    Write-Warn "pwsh (PowerShell 7) isn't on PATH in this session yet - restart your terminal and re-run this script to finish this step"
} else {
    $targetProfile = pwsh -NoProfile -Command '$PROFILE'
    $targetDir = Split-Path $targetProfile -Parent
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

    if (Test-Path $targetProfile) {
        $backup = "$targetProfile.bak-$(Get-Date -Format 'yyyyMMddHHmmss')"
        Copy-Item $targetProfile $backup
        Write-Warn "Existing profile backed up to $backup"
    }

    Copy-Item (Join-Path $repoRoot 'powershell\Microsoft.PowerShell_profile.ps1') $targetProfile -Force
    Copy-Item (Join-Path $repoRoot 'powershell\tokyonight-custom.omp.json') (Join-Path $targetDir 'tokyonight-custom.omp.json') -Force
    Copy-Item (Join-Path $repoRoot 'powershell\fastfetch.jsonc') (Join-Path $targetDir 'fastfetch.jsonc') -Force
    Write-Ok "Profile deployed to $targetProfile"
}

# ---------------------------------------------------------------------------
Write-Step "Merging Windows Terminal settings"
$possibleSettingsPaths = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
)
$settingsPath = $possibleSettingsPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $settingsPath) {
    Write-Warn "Windows Terminal settings.json not found - install Windows Terminal from the Microsoft Store and re-run this script"
} else {
    $backup = "$settingsPath.bak-$(Get-Date -Format 'yyyyMMddHHmmss')"
    Copy-Item $settingsPath $backup
    Write-Warn "Existing settings.json backed up to $backup"

    $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

    # --- color scheme ---
    if (-not $settings.schemes) { $settings | Add-Member -NotePropertyName schemes -NotePropertyValue @() }
    if (-not ($settings.schemes | Where-Object { $_.name -eq 'Tokyo Night' })) {
        $tokyoNight = [ordered]@{
            name                = 'Tokyo Night'
            background          = '#1A1B26'
            foreground          = '#C0CAF5'
            cursorColor         = '#C0CAF5'
            selectionBackground = '#28344A'
            black               = '#15161E'
            red                 = '#F7768E'
            green               = '#9ECE6A'
            yellow              = '#E0AF68'
            blue                = '#7AA2F7'
            purple              = '#BB9AF7'
            cyan                = '#7DCFFF'
            white               = '#A9B1D6'
            brightBlack         = '#414868'
            brightRed           = '#F7768E'
            brightGreen         = '#9ECE6A'
            brightYellow        = '#E0AF68'
            brightBlue          = '#7AA2F7'
            brightPurple        = '#BB9AF7'
            brightCyan          = '#7DCFFF'
            brightWhite         = '#C0CAF5'
        }
        $settings.schemes += [pscustomobject]$tokyoNight
        Write-Ok "Added 'Tokyo Night' color scheme"
    } else {
        Write-Ok "'Tokyo Night' color scheme already present"
    }

    # --- profile defaults ---
    if (-not $settings.profiles.defaults) {
        $settings.profiles | Add-Member -NotePropertyName defaults -NotePropertyValue ([pscustomobject]@{}) -Force
    }
    $defaults = $settings.profiles.defaults
    $defaultsToApply = [ordered]@{
        colorScheme      = 'Tokyo Night'
        font             = [pscustomobject]@{ face = 'JetBrainsMono NFM'; size = 11 }
        opacity          = 90
        useAcrylic       = $true
        cursorShape      = 'bar'
        antialiasingMode = 'cleartype'
    }
    foreach ($key in $defaultsToApply.Keys) {
        if ($defaults.PSObject.Properties.Name -contains $key) {
            $defaults.$key = $defaultsToApply[$key]
        } else {
            $defaults | Add-Member -NotePropertyName $key -NotePropertyValue $defaultsToApply[$key]
        }
    }
    Write-Ok "Applied Tokyo Night look to profile defaults"

    # --- Quake mode keybinding ---
    if (-not $settings.keybindings) { $settings | Add-Member -NotePropertyName keybindings -NotePropertyValue @() }
    if (-not ($settings.keybindings | Where-Object { $_.id -eq 'Terminal.QuakeMode' })) {
        $settings.keybindings += [pscustomobject]@{ id = 'Terminal.QuakeMode'; keys = 'win+`' }
        Write-Ok "Added Quake mode keybinding (Win+``)"
    } else {
        Write-Ok "Quake mode keybinding already present"
    }

    # --- offer to set PowerShell 7 as default profile ---
    $pwshProfile = $settings.profiles.list | Where-Object {
        $_.source -eq 'Windows.Terminal.PowershellCore' -or $_.commandline -match 'pwsh\.exe'
    } | Select-Object -First 1

    if ($pwshProfile) {
        if ($pwshProfile.PSObject.Properties.Name -notcontains 'tabColor') {
            $pwshProfile | Add-Member -NotePropertyName tabColor -NotePropertyValue '#7AA2F7'
        } else {
            $pwshProfile.tabColor = '#7AA2F7'
        }

        $answer = Read-Host "    Set PowerShell 7 as your default Windows Terminal profile? [Y/n]"
        if ($answer -notmatch '^[nN]') {
            $settings.defaultProfile = $pwshProfile.guid
            Write-Ok "PowerShell 7 set as default profile"
        }
    } else {
        Write-Warn "No PowerShell 7 profile found yet - open a new Windows Terminal tab once, then re-run this script to finish this step"
    }

    ($settings | ConvertTo-Json -Depth 20) | Set-Content -Path $settingsPath -Encoding utf8
    Write-Ok "settings.json updated"
}

# ---------------------------------------------------------------------------
Write-Host "`nAll done! Close every Windows Terminal window and open a new one to see it in action." -ForegroundColor Magenta
Write-Host "Tip: press Win+``` (backtick) from anywhere to summon/hide Windows Terminal - Quake mode." -ForegroundColor Magenta
