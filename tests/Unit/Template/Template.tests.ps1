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

Describe Get-Something {
    BeforeAll{
        # Mock Private functions (requires -ModuleName for Pester v5)
    }

    Context 'Return values' {
        BeforeEach {
            $return = Get-Something -Data 'value'
        }

        It 'Returns a single object' {
            ($return | Measure-Object).Count | Should -Be 1
        }
    }

    Context 'Pipeline' {
        It 'Accepts values from the pipeline by value' {
            $return = 'value1', 'value2' | Get-Something

            $return[0] | Should -Be 'value1'
            $return[1] | Should -Be 'value2'
        }

        It 'Accepts value from the pipeline by property name' {
            $return = 'value1', 'value2' | ForEach-Object {
                [PSCustomObject]@{
                    Data          = $_
                    OtherProperty = 'other'
                }
            } | Get-Something


            $return[0] | Should -Be 'value1'
            $return[1] | Should -Be 'value2'
        }
    }

    Context 'ShouldProcess' {
        It 'Supports WhatIf' {
            (Get-Command Get-Something).Parameters.ContainsKey('WhatIf') | Should -Be $true
            { Get-Something -Data 'value' -WhatIf } | Should -Not -Throw
        }
    }
}
