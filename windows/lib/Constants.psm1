<#
.SYNOPSIS
  zsh スクリプトを移植した PowerShell モジュール

.DESCRIPTION
  - SCRIPT_VERSION, NVM_VERSION, DEFAULT_*_VERSION を読み取り専用で定義
  - CPU_ARCH, WindowsVersion を取得
#>

#region モジュール変数定義

# バージョン情報
Set-Variable -Name ScriptVersion `
             -Value '1.2.0' `
             -Option ReadOnly

Set-Variable -Name NvmVersion `
             -Value '0.40.2' `
             -Option ReadOnly

# デフォルトバージョン
Set-Variable -Name DefaultNodeVersion `
             -Value '22.15.0' `
             -Option ReadOnly

Set-Variable -Name DefaultPythonVersion `
             -Value '3.12.10' `
             -Option ReadOnly

Set-Variable -Name DefaultAnsibleVersion `
             -Value '2.17.11' `
             -Option ReadOnly

# ホスト情報取得
# CPU アーキテクチャーを取得
$cpuArch = $env:PROCESSOR_ARCHITECTURE
Set-Variable -Name CpuArch `
             -Value $cpuArch `
             -Option ReadOnly

# Windows バージョン取得
$windowsVersion = (Get-CimInstance -ClassName Win32_OperatingSystem).Version.Trim()
Set-Variable -Name WindowsVersion `
             -Value $windowsVersion `
             -Option ReadOnly

#endregion

#region エクスポート設定

# モジュール利用側から変数を参照可能にする
Export-ModuleMember -Variable `
  ScriptVersion, `
  NvmVersion, `
  DefaultNodeVersion, `
  DefaultPythonVersion, `
  DefaultAnsibleVersion, `
  CpuArch, `
  WindowsVersion

#endregion
