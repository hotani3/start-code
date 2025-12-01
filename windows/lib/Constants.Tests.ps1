<#
.SYNOPSIS
    Pester tests for Constants.psm1
.DESCRIPTION
    Unit tests for each constant using Pester v3.4.0
#>

Describe 'Test Constants.psm1' {

    # Load the module under test
    BeforeAll {
        Import-Module (Join-Path $PSScriptRoot 'Constants.psm1') -Force
    }
    
    Context 'Version constants' {
        It 'defines ScriptVersion as 1.2.1' {
            $ScriptVersion | Should Be '1.2.1'
        }
        It 'defines NvmVersion as 0.40.3' {
            $NvmVersion | Should Be '0.40.3'
        }
        It 'defines DefaultNodeVersion as 22.20.0' {
            $DefaultNodeVersion | Should Be '22.20.0'
        }
        It 'defines DefaultPythonVersion as 3.12.12' {
            $DefaultPythonVersion | Should Be '3.12.12'
        }
        It 'defines DefaultAnsibleVersion as 2.18.10' {
            $DefaultAnsibleVersion | Should Be '2.18.10'
        }
    }

    Context 'System constants' {
        It 'defines CpuArch matching PROCESSOR_ARCHITECTURE env var' {
            $CpuArch | Should Be $env:PROCESSOR_ARCHITECTURE
        }
        It 'defines WindowsVersion in valid version format' {
            $WindowsVersion | Should Match '^\d+\.\d+(?:\.\d+)?'
        }
    }

}
