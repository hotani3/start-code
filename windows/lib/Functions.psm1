# Functions.psm1

# モジュール自身のファイル名をスクリプト名として保持
$script:SCRIPT_NAME = Split-Path -Leaf $PSCommandPath

# Windows のバージョンを取得
try {
    $script:WindowsVersion = (Get-CimInstance Win32_OperatingSystem).Version
} catch {
    Write-Error "Failed to retrieve Windows version: $_"
    exit 1
}

# CPU アーキテクチャを取得
$script:CPUArchitecture = $env:PROCESSOR_ARCHITECTURE

function Assert-VersionFormat {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Version
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    if ($Version -notmatch '^[0-9]+\.[0-9]+\.[0-9]+$') {
        Write-Error "[$timestamp] ERROR $SCRIPT_NAME: Invalid version format: $Version"
        exit 1
    }
}

function Assert-NodeVersionAlias {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Version
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    if ((-not ($Version -match '^(stable|lts/\*|lts/iron|lts/jod)$')) -and
        (-not ($Version -match '^[0-9]+(\.[0-9]+){0,2}$'))) {
        Write-Error "[$timestamp] ERROR $SCRIPT_NAME: Invalid version format: $Version"
        exit 1
    }
}

function Resolve-NodeVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Alias
    )
    # スクリプト変数 DEFAULT_NODE_VERSION が事前に設定されている想定
    $version = $script:DEFAULT_NODE_VERSION

    if ($Alias -eq 'stable') {
        $version = nvm ls-remote --no-colors |
                   Select-String -Pattern '[0-9]+\.[0-9]+\.[0-9]+' |
                   ForEach-Object { $_.Matches } |
                   Select-Object -Last 1 |
                   ForEach-Object { $_.Value }
    }
    elseif ($Alias -match '^(lts/\*|lts/iron|lts/jod)$' -or $Alias -match '^[0-9]+(\.[0-9]+){0,1}$') {
        $version = nvm ls-remote --no-colors $Alias |
                   Select-String -Pattern '[0-9]+\.[0-9]+\.[0-9]+' |
                   ForEach-Object { $_.Matches } |
                   Select-Object -Last 1 |
                   ForEach-Object { $_.Value }
    }
    else {
        $version = $Alias
    }

    Write-Output $version
}

function Assert-AnsibleVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Version
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    if ($Version -notmatch '^2\.(17|18)\.[0-9]+$') {
        Write-Error "[$timestamp] ERROR $SCRIPT_NAME: Unsupported Ansible version: $Version"
        exit 1
    }
}

function Assert-AnsibleAndPythonVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$AnsibleVersion,
        [Parameter(Mandatory)][string]$PythonVersion
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    if ($AnsibleVersion -match '^2\.17\.[0-9]+$') {
        if ($PythonVersion -notmatch '^3\.(10|11|12)\.[0-9]+$') {
            Write-Error "[$timestamp] ERROR $SCRIPT_NAME: Ansible $AnsibleVersion requires Python 3.10-12"
            exit 1
        }
    }
    elseif ($AnsibleVersion -match '^2\.18\.[0-9]+$') {
        if ($PythonVersion -notmatch '^3\.(11|12|13)\.[0-9]+$') {
            Write-Error "[$timestamp] ERROR $SCRIPT_NAME: Ansible $AnsibleVersion requires Python 3.11-13"
            exit 1
        }
    }
}

function Execute {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$StartMessage,
        [Parameter(Mandatory)][string]$Command,
        [Parameter(Mandatory)][string]$ErrorMessage
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] INFO $SCRIPT_NAME: $StartMessage"
    Invoke-Expression $Command
    if ($LASTEXITCODE -ne 0) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Error "[$timestamp] ERROR $SCRIPT_NAME: $ErrorMessage"
        exit 1
    }
}

function Find-LatestOfMinorVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$VersionsCommand,
        [Parameter(Mandatory)][string]$MinorVersion
    )
    $pattern = "$([Regex]::Escape($MinorVersion))\.[0-9]+"
    $latest = Invoke-Expression $VersionsCommand |
              Select-String -Pattern $pattern |
              ForEach-Object { $_.Matches } |
              Select-Object -Last 1 |
              ForEach-Object { $_.Value }
    Write-Output $latest
}

function Detect {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$PackageTitle,
        [Parameter(Mandatory)][string]$DetectCommand,
        [Parameter(Mandatory)][string]$VersionCommand,
        [switch]$ExitOnFail
    )
    # 検出コマンドを実行
    Invoke-Expression $DetectCommand
    if ($LASTEXITCODE -eq 0) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $version = Invoke-Expression $VersionCommand
        Write-Host "[$timestamp] INFO $SCRIPT_NAME: Detected $PackageTitle $version"
        return 0
    }
    else {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        if ($ExitOnFail) {
            Write-Error "[$timestamp] ERROR $SCRIPT_NAME: Failed to detect $PackageTitle"
            exit 1
        }
        else {
            Write-Host "[$timestamp] WARN  $SCRIPT_NAME: Failed to detect $PackageTitle"
            return 1
        }
    }
}

function Install {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$PackageTitle,
        [Parameter(Mandatory)][string]$InstallCommand
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] INFO $SCRIPT_NAME: Installing $PackageTitle..."
    Invoke-Expression $InstallCommand
    if ($LASTEXITCODE -eq 0) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Host "[$timestamp] INFO $SCRIPT_NAME: Successfully installed $PackageTitle!"
    }
    else {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Error "[$timestamp] ERROR $SCRIPT_NAME: Failed to install $PackageTitle"
        exit 1
    }
}

Export-ModuleMember -Function `
    Assert-VersionFormat, `
    Assert-NodeVersionAlias, `
    Resolve-NodeVersion, `
    Assert-AnsibleVersion, `
    Assert-AnsibleAndPythonVersion, `
    Execute, `
    Find-LatestOfMinorVersion, `
    Detect, `
    Install
