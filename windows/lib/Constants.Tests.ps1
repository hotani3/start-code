# Constants.Tests.ps1
# Pester tests for Constants.psm1 (requires Pester 3.4.0)

Describe 'Constants module' {

    # Load the module under test
    BeforeAll {
        Import-Module (Join-Path $PSScriptRoot 'Constants.psm1') -Force
    }
    
    Context 'Version constants' {
        It 'defines ScriptVersion as 1.2.0' {
            $ScriptVersion | Should Be '1.2.0'
        }
        It 'defines NvmVersion as 0.40.2' {
            $NvmVersion | Should Be '0.40.2'
        }
        It 'defines DefaultNodeVersion as 22.15.0' {
            $DefaultNodeVersion | Should Be '22.15.0'
        }
        It 'defines DefaultPythonVersion as 3.12.10' {
            $DefaultPythonVersion | Should Be '3.12.10'
        }
        It 'defines DefaultAnsibleVersion as 2.17.11' {
            $DefaultAnsibleVersion | Should Be '2.17.11'
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
