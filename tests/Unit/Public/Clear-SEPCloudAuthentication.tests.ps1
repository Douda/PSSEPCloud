BeforeAll {
    $script:moduleName = 'PSSEPCloud'

    # If the module is not found, run the build task 'noop'.
    if (-not (Get-Module -Name $script:moduleName -ListAvailable))
    {
        # Redirect all streams to $null, except the error stream (stream 2)
        & "$PSScriptRoot/../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
    }

    # Re-import the module using force to get any code changes between runs.
    Import-Module -Name $script:moduleName #-Force -ErrorAction 'Stop'

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

Describe Clear-SEPCloudAuthentication {
    BeforeAll {
        Mock -CommandName Test-SEPCloudToken -MockWith { $PrivateData }
    Mock -CommandName Remove-Item -MockWith { "Mocked Remove-Item" }
    }
    

    Context 'ShouldProcess' {
        It 'Supports WhatIf' {
            (Get-Command Clear-SEPCloudAuthentication).Parameters.ContainsKey('WhatIf') | Should -Be $true
            { Clear-SEPCloudAuthentication -WhatIf } | Should -Not -Throw
        }

        It 'Does not call Test-SEPCloudToken if WhatIf is set' {
            Clear-SEPCloudAuthentication -WhatIf
            Assert-MockCalled Test-SEPCloudToken -Times 0 -Scope It
        }
    }
}
