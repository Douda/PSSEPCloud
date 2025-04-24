BeforeAll {
    $script:moduleName = 'PSSEPCloud'
    $ProjectPath = "$PSScriptRoot/../../.." | Convert-Path

    # Redirect all streams to $null, except the error stream (stream 2)
    & "$ProjectPath/build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null

    # Not Forcing module import
    # See reasons behind Pester v5 : https://github.com/pester/Pester/discussions/2109
    # Requires to build module prior running Pester
    Import-Module -Name $script:moduleName -ErrorAction 'Stop'
}

AfterAll {
    Remove-Module -Name $script:moduleName
}


Describe 'Get-SEPCloudComponentType' {
    BeforeAll {
        # Mock Private functions (requires -ModuleName for Pester v5)
        Mock Test-SEPCloudConnection -ModuleName $script:moduleName -MockWith { $true }
        Mock Submit-Request -ModuleName $script:moduleName -MockWith {
            return [PSCustomObject]@{
                total       = 1000
                total_count = 1000
                data        = @(1..1000)
            }
        }

    }

    Context 'Return values' {
        BeforeAll {}

        It 'Returns a list of objects' {
            $result = Get-SEPCloudComponentType -ComponentType "network-ips"
            ($result | Measure-Object).Count | Should -Be 1000
        }

        It 'hit pagination' {
            Mock Submit-Request -ModuleName $script:moduleName -MockWith {
                return [PSCustomObject]@{
                    total       = 2000
                    total_count = 2000
                    data        = @(1..1000)
                }
            }
            Get-SEPCloudComponentType -ComponentType "network-ips"
            Should -Invoke -CommandName Submit-Request -ModuleName $script:moduleName -Times 2
        }
    }
}
