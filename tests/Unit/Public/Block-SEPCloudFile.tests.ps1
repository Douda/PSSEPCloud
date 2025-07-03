BeforeAll {
    $script:moduleName = 'PSSEPCloud'

    # If the module is not found, run the build task 'noop'.
    if (-not (Get-Module -Name $script:moduleName -ListAvailable)) {
        # Redirect all streams to $null, except the error stream (stream 2)
        & "$PSScriptRoot/../../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
    }

    # Re-import the module using force to get any code changes between runs.
    Import-Module -Name $script:moduleName -Force -ErrorAction 'Stop'

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:moduleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    Remove-Module -Name $script:moduleName
}

Describe Block-SEPCloudFile {
    BeforeEach {
        # Mock Private functions (requires -ModuleName for Pester v5)
        Mock Test-SEPCloudConnection -ModuleName $script:moduleName -MockWith { $true }
        Mock Get-SEPCloudAPIData -ModuleName $script:moduleName -MockWith { 
            return @{ 
                URI = "test"
                Method = "POST"
                Body = @{}
                Query = @{}
                Result = ""
                ObjectTName = "TestObject"
            } 
        }
        Mock Submit-Request -ModuleName $script:moduleName -MockWith { return "Mocked Response" }
        Mock Invoke-SEPCloudWebRequest -ModuleName $script:moduleName -MockWith { return "Mocked Response" }
        Mock New-URIString -ModuleName $script:moduleName -MockWith { return "http://test.com" }
        Mock Test-QueryParam -ModuleName $script:moduleName -MockWith { return "http://test.com" }
        Mock New-BodyString -ModuleName $script:moduleName -MockWith { return "test body" }
        Mock Test-ReturnFormat -ModuleName $script:moduleName -MockWith { return $args[0] }
        Mock Set-ObjectTypeName -ModuleName $script:moduleName -MockWith { return $args[1] }
    }

    Context 'Return values' {
        It 'Does not throw when parameters are provided' {
            { Block-SEPCloudFile -device_ids 'test_device_id' -hash 'test_hash' -WhatIf } | Should -Not -Throw
        }

    }

    Context 'Parameter Validation' {
        It 'Accepts device_ids parameter' {
            { Block-SEPCloudFile -device_ids 'test_device_id' -hash 'test_hash' -WhatIf } | Should -Not -Throw
        }

        It 'Accepts hash parameter' {
            { Block-SEPCloudFile -device_ids 'test_device_id' -hash 'test_hash' -WhatIf } | Should -Not -Throw
        }
    }

    Context 'ShouldProcess' {
        It 'Supports WhatIf' {
            (Get-Command Block-SEPCloudFile).Parameters.ContainsKey('WhatIf') | Should -Be $true
            { Block-SEPCloudFile -device_ids 'test_device_id' -hash 'test_hash' -WhatIf } | Should -Not -Throw
        }


    }
}