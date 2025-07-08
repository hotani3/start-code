<#
.SYNOPSIS
    Pester tests for Functions.psm1
.DESCRIPTION
    Unit tests for each function using Pester v3.4.0
#>

# モジュール自身のファイル名をスクリプト名として保持
$script:SCRIPT_NAME = Split-Path -Leaf $PSCommandPath

Describe 'Test Functions.psm1' {

    # Load the module under test
    BeforeAll {
        Import-Module (Join-Path $PSScriptRoot 'Functions.psm1') -Force
    }

    Context 'Assert-VersionFormat' {
        It 'Should not throw for valid version' {
            { Assert-VersionFormat -Version '1.2.3' } | Should Not Throw
        }
        It 'Should throw for invalid version' {
            { Assert-VersionFormat -Version '1.2' } | Should Throw
        }
    }

    Context 'Assert-NodeVersionAlias' {
        It 'Should not throw for valid alias stable' {
            { Assert-NodeVersionAlias -Version 'stable' } | Should Not Throw
        }
        It 'Should not throw for numeric alias' {
            { Assert-NodeVersionAlias -Version '14.15' } | Should Not Throw
        }
        It 'Should throw for invalid alias' {
            { Assert-NodeVersionAlias -Version 'invalid/alias' } | Should Throw
        }
    }

    Context 'Resolve-NodeVersion' {
        It 'Should return alias directly if numeric' {
            (Resolve-NodeVersion -Alias '3.8.0') | Should Be '3.8.0'
        }
    }

    Context 'Assert-AnsibleVersion' {
        It 'Should not throw for 2.17.x' {
            { Assert-AnsibleVersion -Version '2.17.5' } | Should Not Throw
        }
        It 'Should not throw for 2.18.x' {
            { Assert-AnsibleVersion -Version '2.18.1' } | Should Not Throw
        }
        It 'Should throw for unsupported version' {
            { Assert-AnsibleVersion -Version '2.19.0' } | Should Throw
        }
    }

    Context 'Assert-AnsibleAndPythonVersion' {
        It 'Should not throw for Python 3.10.x' {
            { Assert-AnsibleAndPythonVersion -AnsibleVersion '2.17.1' -PythonVersion '3.10.2' } | Should Not Throw
        }
        It 'Should throw for Python <3.10' {
            { Assert-AnsibleAndPythonVersion -AnsibleVersion '2.17.1' -PythonVersion '3.9.9' } | Should Throw
        }

        It 'Should not throw for Python 3.11.x' {
            { Assert-AnsibleAndPythonVersion -AnsibleVersion '2.18.3' -PythonVersion '3.11.4' } | Should Not Throw
        }
        It 'Should throw for Python <3.11' {
            { Assert-AnsibleAndPythonVersion -AnsibleVersion '2.18.3' -PythonVersion '3.10.5' } | Should Throw
        }
    }

    Context 'Execute' {
        <#
        It 'Should run command and output result' {
            $output = & { Execute -StartMessage 'Show help of Scoop' -Command 'scoop help' -ErrorMessage 'Failed to show help of Scoop' }
            $output | Should Contain 'Available commands are listed below.'
        }
        #>
        It 'Should return 0 when a command succeeds' {
            $result = & { Execute -StartMessage 'Show help of Git' -Command 'git help' -ErrorMessage 'Failed to show help of Git' }
            $result | Should Be 0
        }
        It 'Should throw when a command fails' {
            { Execute -StartMessage 'Execute a missing command' -Command 'missing' -ErrorMessage 'Failed to execute the "missing"' } | Should Throw
        }
    }

    Context 'Find-LatestOfMinorVersion' {
        It 'Should find last matching version' {
            $command = 'Write-Output "1.2.1`n1.2.2`n1.3.0"'
            (Find-LatestOfMinorVersion -VersionsCommand $command -MinorVersion '1.2') | Should Be '1.2.2'
        }
    }

    Context 'Detect' {
        It 'Should return 0 when detection succeeds' {
            $result = & { Detect -PackageTitle 'Git' -DetectCommand 'git -v > $null 2>&1' -VersionCommand '(git -v | Select-String "version\s+(\d+\.\d+\.\d+)").Matches[0].Groups[1].Value' }
            $result | Should Be 0
        }
        It 'Should not throw when detection fails without ExitOnFail' {
            $result = & { Detect -PackageTitle 'Pkg' -DetectCommand 'cmd /c exit 1' -VersionCommand 'Write-Output "v1"' }
            $result | Should Be 1
        }
        It 'Should throw when detection fails with ExitOnFail' {
            { Detect -PackageTitle 'Pkg' -DetectCommand 'cmd /c exit 1' -VersionCommand 'Write-Output "v1"' -ExitOnFail } | Should Throw
        }
    }

    Context 'Install' {
        It 'Should throw on installation failure' {
            { Install -PackageTitle 'Pkg' -InstallCommand 'cmd /c exit 1' } | Should Throw
        }
    }

}
