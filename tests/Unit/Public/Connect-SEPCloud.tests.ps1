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

Describe Connect-SEPCloud {
    Context 'When called with valid parameters' {
        It 'should create a valid header with token' {
            # Arrange
            $clientId = 'validClientId'
            $secret = 'validSecret'
            $mockToken = [PSCustomObject]@{ Token_Bearer = 'validToken' }
            Mock Get-SEPCloudToken  { return $mockToken }

            # Act
            Connect-SEPCloud -clientId $clientId -secret $secret

            # Assert
                        $script:SEPCloudConnection.header.Authorization | Should -Be 'validToken'
                        $script:SEPCloudConnection.header.'User-Agent' | Should -Be 'UserAgentString'
        }
    }

    Context 'ShouldProcess' {
        It 'Supports WhatIf' {
            (Get-Command Connect-SEPCloud).Parameters.ContainsKey('WhatIf') | Should -Be $true
            { Connect-SEPCloud -clientId 'value' -WhatIf } | Should -Not -Throw
        }
    }
}
