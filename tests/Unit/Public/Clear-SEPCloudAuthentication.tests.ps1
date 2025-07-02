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

Describe Clear-SEPCloudAuthentication {
    BeforeAll {
        Mock -CommandName Remove-Item -MockWith { "Mocked Remove-Item" }
    }

    Context 'ShouldProcess' {
        It 'Supports WhatIf' {
            (Get-Command Clear-SEPCloudAuthentication).Parameters.ContainsKey('WhatIf') | Should -Be $true
        }

        It 'Supports Confirm' {
            (Get-Command Clear-SEPCloudAuthentication).Parameters.ContainsKey('Confirm') | Should -Be $true
        }

        It 'Does not execute when WhatIf is used' {
            InModuleScope -Parameters @{} -ScriptBlock {
                # Initialize script variables that the function checks
                $script:configuration = @{
                    CachedTokenPath = "TestPath1"
                    SEPCloudCredsPath = "TestPath2"
                    CachedToken = "TestToken"
                }
                $script:Credential = "TestCredential"
                $script:SEPCloudConnection = @{
                    AccessToken = "TestAccessToken"
                    Credential = "TestConnectionCredential"
                }

                Clear-SEPCloudAuthentication -WhatIf
                
                # Variables should not be cleared when using WhatIf
                $script:configuration.CachedToken | Should -Be "TestToken"
                $script:Credential | Should -Be "TestCredential"
                $script:SEPCloudConnection.AccessToken | Should -Be "TestAccessToken"
                $script:SEPCloudConnection.Credential | Should -Be "TestConnectionCredential"
            }
            
            # Remove-Item should not be called with WhatIf
            Should -Invoke Remove-Item -Times 0 -Scope It
        }

        It 'Executes normally without WhatIf' {
            InModuleScope -Parameters @{} -ScriptBlock {
                # Initialize script variables that the function checks
                $script:configuration = @{
                    CachedTokenPath = "TestPath1"
                    SEPCloudCredsPath = "TestPath2"
                    CachedToken = "TestToken"
                }
                $script:Credential = "TestCredential"
                $script:SEPCloudConnection = @{
                    AccessToken = "TestAccessToken"
                    Credential = "TestConnectionCredential"
                }

                Clear-SEPCloudAuthentication -Confirm:$false
                
                # Variables should be cleared when executing normally
                $script:configuration.CachedToken | Should -BeNullOrEmpty
                $script:Credential | Should -BeNullOrEmpty
                $script:SEPCloudConnection.AccessToken | Should -BeNullOrEmpty
                $script:SEPCloudConnection.Credential | Should -BeNullOrEmpty
            }
            
            # Remove-Item should be called twice (for both paths)
            Should -Invoke Remove-Item -Times 2 -Scope It
        }

        It 'Handles null variables gracefully' {
            InModuleScope -Parameters @{} -ScriptBlock {
                # Initialize only configuration, leave other variables null
                $script:configuration = @{
                    CachedTokenPath = "TestPath1"
                    SEPCloudCredsPath = "TestPath2"
                }
                $script:Credential = $null
                $script:SEPCloudConnection = @{}

                { Clear-SEPCloudAuthentication -Confirm:$false } | Should -Not -Throw
            }
        }
    }

    Context 'Function Execution' {
        It 'Should not throw when executed' {
            InModuleScope -Parameters @{} -ScriptBlock {
                $script:configuration = @{
                    CachedTokenPath = "TestPath1"
                    SEPCloudCredsPath = "TestPath2"
                }
                
                { Clear-SEPCloudAuthentication -Confirm:$false } | Should -Not -Throw
            }
        }
    }
}
