$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
    }).BaseName


Import-Module $ProjectName

InModuleScope $ProjectName {
    Describe Test-SEPCloudConnection {
        Context 'Default' {
            BeforeEach {
                $command = Get-Command -Name 'Test-SEPCloudConnection' -ErrorAction SilentlyContinue
            }

            It 'Should exist' { $command | Should -Not -BeNullOrEmpty }

            It 'Should be a function' { $command.CommandType | Should -Be 'Function' }
        }

        Context 'ShouldProcess' {
            BeforeEach {
                $command = Get-Command -Name 'Test-SEPCloudConnection' -ErrorAction SilentlyContinue
            }

            It 'Does not support WhatIf (read-only function)' {
                $command.Parameters.ContainsKey('WhatIf') | Should -Be $false
            }

            It 'Does not support Confirm (read-only function)' {
                $command.Parameters.ContainsKey('Confirm') | Should -Be $false
            }
        }

        Context 'Function Behavior' {
            BeforeAll {
                Mock -CommandName Test-SEPCloudToken -MockWith { $true }
                Mock -CommandName Get-SEPCloudToken -MockWith { }
                Mock -CommandName Write-Verbose -MockWith { }
            }

            It 'Returns true when token is valid' {
                Mock -CommandName Test-SEPCloudToken -MockWith { $true }
                
                $script:SEPCloudConnection = @{
                    BaseURL = 'test.example.com'
                    AccessToken = @{
                        Token = 'test-token'
                        Expiration = (Get-Date).AddHours(1)
                    }
                }
                
                $result = Test-SEPCloudConnection
                $result | Should -Be $true
                Should -Invoke Test-SEPCloudToken -Times 1 -Scope It
                Should -Invoke Get-SEPCloudToken -Times 0 -Scope It
            }

            It 'Requests new token when current token is invalid' {
                Mock -CommandName Test-SEPCloudToken -MockWith { $false }
                Mock -CommandName Get-SEPCloudToken -MockWith { 
                    $script:SEPCloudConnection.AccessToken = @{
                        Token = 'new-token'
                        Expiration = (Get-Date).AddHours(1)
                    }
                }
                
                $script:SEPCloudConnection = @{
                    BaseURL = 'test.example.com'
                    AccessToken = @{
                        Token = 'expired-token'
                        Expiration = (Get-Date).AddHours(-1)
                    }
                }
                
                Test-SEPCloudConnection
                Should -Invoke Test-SEPCloudToken -Times 1 -Scope It
                Should -Invoke Get-SEPCloudToken -Times 1 -Scope It
            }
        }
    }
}


