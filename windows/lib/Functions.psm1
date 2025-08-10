# Functions.psm1

# モジュール自身のファイル名をスクリプト名として保持
# $script:ScriptName = Split-Path -Leaf $PSCommandPath

$scriptName = Split-Path -Leaf $PSCommandPath
Set-Variable -Name ScriptName `
             -Value $scriptName `
             -Scope Script `
             -Option ReadOnly

# Windows のバージョンを取得
try {
    $script:WindowsVersion = (Get-CimInstance Win32_OperatingSystem).Version
} catch {
    Write-Error "Failed to retrieve Windows version: $_"
    throw
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
        Write-Error "[$timestamp] ERROR $script:ScriptName: Invalid version format: $Version"
        throw
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
        Write-Error "[$timestamp] ERROR $script:ScriptName: Invalid version format: $Version"
        throw
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
        Write-Error "[$timestamp] ERROR $script:ScriptName: Unsupported Ansible version: $Version"
        throw
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
            Write-Error "[$timestamp] ERROR $script:ScriptName: Ansible $AnsibleVersion requires Python 3.10-12"
            throw
        }
    }
    elseif ($AnsibleVersion -match '^2\.18\.[0-9]+$') {
        if ($PythonVersion -notmatch '^3\.(11|12|13)\.[0-9]+$') {
            Write-Error "[$timestamp] ERROR $script:ScriptName: Ansible $AnsibleVersion requires Python 3.11-13"
            throw
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
    Write-Host "[$timestamp] INFO $script:ScriptName: $StartMessage"
    $result = Invoke-Expression $Command
    if ($LASTEXITCODE -eq 0) {
        return 0
    }
    else {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Error "[$timestamp] ERROR $script:ScriptName: $ErrorMessage"
        throw
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
    $result = Invoke-Expression $DetectCommand
    if ($LASTEXITCODE -eq 0) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $version = Invoke-Expression $VersionCommand
        Write-Host "[$timestamp] INFO $script:ScriptName: Detected $PackageTitle $version"
        return 0
    }
    else {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        if ($ExitOnFail) {
            Write-Error "[$timestamp] ERROR $script:ScriptName: Failed to detect $PackageTitle"
            throw
        }
        else {
            Write-Host "[$timestamp] WARN  $script:ScriptName: Failed to detect $PackageTitle"
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
    Write-Host "[$timestamp] INFO $script:ScriptName: Installing $PackageTitle..."
    $result = Invoke-Expression $InstallCommand
    if ($LASTEXITCODE -eq 0) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Host "[$timestamp] INFO $script:ScriptName: Successfully installed $PackageTitle!"
        return 0
    }
    else {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Error "[$timestamp] ERROR $script:ScriptName: Failed to install $PackageTitle"
        throw
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
