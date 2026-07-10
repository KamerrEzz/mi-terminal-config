#Requires -Version 5.1
<#
.SYNOPSIS
    Instala y configura este setup de Windows Terminal + PowerShell 7:
    tema Tokyo Night, prompt de Oh My Posh (con segmentos de pnpm/node/git),
    banner de fastfetch, zoxide, eza, fzf, Terminal-Icons y el atajo de modo Quake.

.DESCRIPTION
    Se puede correr las veces que quieras. Los archivos existentes se respaldan
    antes de tocarlos, y el settings.json de Windows Terminal se mezcla (no se
    reemplaza), así que tus otros perfiles y ajustes quedan intactos.
#>

$ErrorActionPreference = 'Stop'
$repoRoot = $PSScriptRoot

function Write-Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "    OK  $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "    !!  $msg" -ForegroundColor Yellow }

# Cuando el repo se descarga como ZIP desde GitHub, Windows marca todos sus
# archivos con la "Mark of the Web" (zone identifier). Si no se limpia acá,
# Copy-Item la arrastra a los archivos que este script copia al perfil del
# usuario (por ejemplo Microsoft.PowerShell_profile.ps1), y pwsh los bloquea
# como "no firmado digitalmente" en cualquier sesión nueva.
Get-ChildItem -Path $repoRoot -Recurse -File | Unblock-File -ErrorAction SilentlyContinue

# ---------------------------------------------------------------------------
Write-Step "Revisando requisitos"
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget no está disponible. Instalá 'App Installer' desde la Microsoft Store primero: https://aka.ms/getwinget"
}
Write-Ok "winget encontrado"

# ---------------------------------------------------------------------------
Write-Step "Instalando paquetes con winget (salta lo que ya esté instalado)"
$packages = @(
    'Microsoft.PowerShell',
    'JanDeDobbeleer.OhMyPosh',
    'Fastfetch-cli.Fastfetch',
    'ajeetdsouza.zoxide',
    'eza-community.eza',
    'junegunn.fzf'
)
foreach ($id in $packages) {
    Write-Host "    instalando $id ..."
    winget install -e --id $id --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
}
Write-Ok "Instalación de paquetes lista"

# Refresca el PATH en esta sesión para que los binarios recién instalados se
# puedan usar en los pasos siguientes
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
            [System.Environment]::GetEnvironmentVariable('Path', 'User')

# ---------------------------------------------------------------------------
Write-Step "Instalando la Nerd Font JetBrainsMono"
Add-Type -AssemblyName System.Drawing
$fontAlreadyInstalled = [bool](
    (New-Object System.Drawing.Text.InstalledFontCollection).Families |
    Where-Object { $_.Name -like 'JetBrainsMono NF*' }
)
if ($fontAlreadyInstalled) {
    Write-Ok "La fuente ya estaba instalada"
} elseif (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    # `oh-my-posh font install` se puede quedar colgado después de terminar en
    # hosts no interactivos/sin consola real - nunca dejar que esto bloquee el
    # resto de la instalación.
    $job = Start-Job -ScriptBlock { oh-my-posh font install JetBrainsMono }
    if (Wait-Job $job -Timeout 60) {
        Receive-Job $job -ErrorAction SilentlyContinue | Out-Null
        Write-Ok "Fuente instalada"
    } else {
        Write-Warn "La instalación de la fuente está tardando demasiado - instalala vos mismo con: oh-my-posh font install JetBrainsMono"
    }
    Remove-Job $job -Force -ErrorAction SilentlyContinue
} else {
    Write-Warn "oh-my-posh todavía no está en el PATH - reiniciá tu terminal y volvé a correr este script para instalar la fuente"
}

# ---------------------------------------------------------------------------
Write-Step "Instalando módulos de PowerShell"

# Asegura que NuGet y la confianza en PSGallery estén listos para que
# Install-Module nunca se detenga a pedir confirmación más abajo.
# -ForceBootstrap es necesario además de -Force: en el PowerShellGet 1.0.0.1
# que trae Windows PowerShell 5.1 por defecto, -Force solo no alcanza para
# suprimir el prompt interactivo de "¿instalar el proveedor NuGet?".
if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ForceBootstrap | Out-Null
}
if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') {
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}

# -AcceptLicense sólo existe en PowerShellGet >= 1.6.0. El PowerShellGet
# 1.0.0.1 que trae Windows PowerShell 5.1 por defecto no tiene ese parámetro,
# así que se agrega solo si el cmdlet instalado lo soporta.
$installModuleParams = @{
    Repository   = 'PSGallery'
    Scope        = 'CurrentUser'
    Force        = $true
    AllowClobber = $true
}
if ((Get-Command Install-Module).Parameters.ContainsKey('AcceptLicense')) {
    $installModuleParams['AcceptLicense'] = $true
}

foreach ($mod in @('Terminal-Icons', 'PSFzf')) {
    if (-not (Get-Module -ListAvailable -Name $mod)) {
        Install-Module -Name $mod @installModuleParams
    }
    Write-Ok "$mod listo"
}

# ---------------------------------------------------------------------------
Write-Step "Desplegando el profile de PowerShell"
if (-not (Get-Command pwsh -ErrorAction SilentlyContinue)) {
    Write-Warn "pwsh (PowerShell 7) todavía no está en el PATH de esta sesión - reiniciá tu terminal y volvé a correr este script para completar este paso"
} else {
    $targetProfile = pwsh -NoProfile -Command '$PROFILE'
    $targetDir = Split-Path $targetProfile -Parent
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

    if (Test-Path $targetProfile) {
        $backup = "$targetProfile.bak-$(Get-Date -Format 'yyyyMMddHHmmss')"
        Copy-Item $targetProfile $backup
        Write-Warn "Profile existente respaldado en $backup"
    }

    Copy-Item (Join-Path $repoRoot 'powershell\Microsoft.PowerShell_profile.ps1') $targetProfile -Force
    Copy-Item (Join-Path $repoRoot 'powershell\tokyonight-custom.omp.json') (Join-Path $targetDir 'tokyonight-custom.omp.json') -Force
    Copy-Item (Join-Path $repoRoot 'powershell\fastfetch.jsonc') (Join-Path $targetDir 'fastfetch.jsonc') -Force
    Write-Ok "Profile desplegado en $targetProfile"
}

# ---------------------------------------------------------------------------
Write-Step "Mezclando la configuración de Windows Terminal"
$possibleSettingsPaths = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
)
$settingsPath = $possibleSettingsPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $settingsPath) {
    Write-Warn "No se encontró el settings.json de Windows Terminal - instalá Windows Terminal desde la Microsoft Store y volvé a correr este script"
} else {
    $backup = "$settingsPath.bak-$(Get-Date -Format 'yyyyMMddHHmmss')"
    Copy-Item $settingsPath $backup
    Write-Warn "settings.json existente respaldado en $backup"

    $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

    # --- esquema de color ---
    if ($settings.PSObject.Properties.Name -notcontains 'schemes') { $settings | Add-Member -NotePropertyName schemes -NotePropertyValue @() }
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
        Write-Ok "Esquema de color 'Tokyo Night' agregado"
    } else {
        Write-Ok "El esquema 'Tokyo Night' ya estaba presente"
    }

    # --- valores por defecto del perfil ---
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
    Write-Ok "Se aplicó el look de Tokyo Night a los valores por defecto del perfil"

    # --- atajo del modo Quake ---
    if ($settings.PSObject.Properties.Name -notcontains 'keybindings') { $settings | Add-Member -NotePropertyName keybindings -NotePropertyValue @() }
    if (-not ($settings.keybindings | Where-Object { $_.id -eq 'Terminal.QuakeMode' })) {
        $settings.keybindings += [pscustomobject]@{ id = 'Terminal.QuakeMode'; keys = 'win+`' }
        Write-Ok "Atajo de modo Quake agregado (Win+``)"
    } else {
        Write-Ok "El atajo de modo Quake ya estaba presente"
    }

    # --- ofrece poner PowerShell 7 como perfil por defecto ---
    $pwshProfile = $settings.profiles.list | Where-Object {
        $_.source -eq 'Windows.Terminal.PowershellCore' -or $_.commandline -match 'pwsh\.exe'
    } | Select-Object -First 1

    if ($pwshProfile) {
        if ($pwshProfile.PSObject.Properties.Name -notcontains 'tabColor') {
            $pwshProfile | Add-Member -NotePropertyName tabColor -NotePropertyValue '#7AA2F7'
        } else {
            $pwshProfile.tabColor = '#7AA2F7'
        }

        $answer = Read-Host "    ¿Poner PowerShell 7 como tu perfil por defecto de Windows Terminal? [Y/n]"
        if ($answer -notmatch '^[nN]') {
            $settings.defaultProfile = $pwshProfile.guid
            Write-Ok "PowerShell 7 configurado como perfil por defecto"
        }
    } else {
        Write-Warn "Todavía no se encontró un perfil de PowerShell 7 - abrí una pestaña nueva de Windows Terminal una vez, y volvé a correr este script para completar este paso"
    }

    ($settings | ConvertTo-Json -Depth 20) | Set-Content -Path $settingsPath -Encoding utf8
    Write-Ok "settings.json actualizado"
}

# ---------------------------------------------------------------------------
Write-Host "`n¡Listo! Cerrá todas las ventanas de Windows Terminal y abrí una nueva para verlo en acción." -ForegroundColor Magenta
Write-Host "Tip: apretá Win+``` (backtick) desde cualquier lado para invocar/ocultar Windows Terminal - modo Quake." -ForegroundColor Magenta
