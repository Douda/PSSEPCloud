BeforeAll {
    $script:moduleName = 'PSSEPCloud'

    # If the module is not found, run the build task 'noop'.
    if (-not (Get-Module -Name $script:moduleName -ListAvailable))
    {
        # Redirect all streams to $null, except the error stream (stream 2)
        & "$PSScriptRoot/../../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
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

Describe Get-SEPCloudToken {

    Context 'Return values' {
        BeforeEach {
            $return = Get-SEPCloudToken
        }

        It 'Returns a single object' {
            ($return | Measure-Object).Count | Should -Be 1
        }

    }

    Context 'Pipeline' {
        BeforeAll {
            Mock -CommandName Invoke-RestMethod -MockWith {
                return @{
                    access_token = "test_token_123"
                    token_type = "Bearer"
                    expires_in = 3600
                }
            }
            Mock -CommandName Test-Path -MockWith { $false }
            Mock -CommandName Export-Clixml -MockWith { }
            Mock -CommandName New-Item -MockWith { }
        }

        It 'Accepts clientId and secret from pipeline by property name' {
            $inputObject = [PSCustomObject]@{
                clientId = 'test-client-id'
                secret = 'test-secret'
            }
            
            InModuleScope -Parameters @{ inputObject = $inputObject } -ScriptBlock {
                $script:SEPCloudConnection = @{
                    baseURL = 'api.sep.securitycloud.symantec.com'
                }
                $script:configuration = @{
                    SEPCloudCredsPath = 'TestCredsPath'
                    cachedTokenPath = 'TestTokenPath'
                }
                
                $result = $inputObject | Get-SEPCloudToken
                $result.Token | Should -Be "test_token_123"
                $result.Token_Type | Should -Be "Bearer"
            }
        }

        It 'Processes multiple objects from pipeline' {
            $inputObjects = @(
                [PSCustomObject]@{ clientId = 'client1'; secret = 'secret1' },
                [PSCustomObject]@{ clientId = 'client2'; secret = 'secret2' }
            )
            
            InModuleScope -Parameters @{ inputObjects = $inputObjects } -ScriptBlock {
                $script:SEPCloudConnection = @{
                    baseURL = 'api.sep.securitycloud.symantec.com'
                }
                $script:configuration = @{
                    SEPCloudCredsPath = 'TestCredsPath'
                    cachedTokenPath = 'TestTokenPath'
                }
                
                $results = $inputObjects | Get-SEPCloudToken
                $results.Count | Should -Be 2
                $results[0].Token | Should -Be "test_token_123"
                $results[1].Token | Should -Be "test_token_123"
            }
        }
    }

    Context 'ShouldProcess' {
        It 'Does not support WhatIf (read-only function)' {
            (Get-Command Get-SEPCloudToken).Parameters.ContainsKey('WhatIf') | Should -Be $false
        }

        It 'Does not support Confirm (read-only function)' {
            (Get-Command Get-SEPCloudToken).Parameters.ContainsKey('Confirm') | Should -Be $false
        }
    }
}
