# Scoop.psm1

# モジュール自身のファイル名をスクリプト名として保持
$scriptName = Split-Path -Leaf $PSCommandPath
Set-Variable -Name ScriptName `
    -Value $scriptName `
    -Scope Script `
    -Option ReadOnly

# 必要なモジュールをインポート
Import-Module $PSScriptRoot\Constants.psm1
Import-Module $PSScriptRoot\Functions.psm1

function Install-Scoop {
    $packageTitle = 'Scoop'
    $detectCommand = 'scoop --version *>&1'
    $versionCommand = "scoop --version *>&1 | Select-String -Pattern 'v?(\d+\.\d+\.\d+)' | ForEach-Object { `$_.Matches.Groups[1].Value } | Select-Object -First 1"
    $installCommand = 'Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression'

    $result = Detect -PackageTitle $packageTitle -DetectCommand $detectCommand -VersionCommand $versionCommand
    if ($result -ne 0) {
        Install -PackageTitle $packageTitle -InstallCommand $installCommand
        Detect -PackageTitle $packageTitle -DetectCommand $detectCommand -VersionCommand $versionCommand -ExitOnFail
    }
}

Export-ModuleMember -Function Install-Scoop
