BeforeAll {
    $script:moduleName = 'PSSEPCloud'

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:moduleName

    Mock -CommandName Submit-Request -MockWith { return "Mocked Response" }
    Mock -CommandName Test-SEPCloudConnection -MockWith { return $true }
    Mock -CommandName Get-SEPCloudAPIData -MockWith { return @{ URI = "test"; Method = "POST"; ObjectTName = "TestObject" } }
}

AfterAll {
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    Remove-Module -Name $script:moduleName
}

Describe Block-SEPCloudFile {
    Context 'Return values' {
        BeforeEach {
            $return = Block-SEPCloudFile -device_ids 'test_device_id' -hash 'test_hash'
        }

        It 'Returns a single object' {
            ($return | Measure-Object).Count | Should -Be 1
        }

    }

    Context 'Pipeline' {
        It 'Does not accept values from the pipeline by value' {
            { 'device_id1', 'device_id2' | Block-SEPCloudFile -hash 'test_hash' } | Should -Throw
        }

        It 'Does not accept value from the pipeline by property name' {
            { 'device_id1', 'device_id2' | ForEach-Object {
                [PSCustomObject]@{
                    device_ids = $_
                    OtherProperty = 'other'
                }
            } | Block-SEPCloudFile -hash 'test_hash' } | Should -Throw
        }
    }

    Context 'ShouldProcess' {
        It 'Supports WhatIf' {
            (Get-Command Block-SEPCloudFile).Parameters.ContainsKey('WhatIf') | Should -Be $true
            { Block-SEPCloudFile -device_ids 'test_device_id' -hash 'test_hash' -WhatIf } | Should -Not -Throw
        }


    }
}