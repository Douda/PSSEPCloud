BeforeAll {
    $script:moduleName = 'PSSEPCloud'

    # If the module is not found, run the build task 'noop'.
    if (-not (Get-Module -Name $script:moduleName -ListAvailable)) {
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

Describe Update-AllowListPolicyByFileName {
    Context 'When called with valid parameters' {
        BeforeAll {
            # Mock the necessary functions
            Mock Test-SEPCloudConnection -ModuleName $ProjectName -MockWith { $true }
            Mock Get-SEPCloudAPIData -ModuleName $ProjectName -MockWith {
                param ($endpoint)
                return @{
                    Description = 'perform partial update of Allow list policy by filename'
                    URI         = '/v1/policies/allow-list/{id}/versions/{id}'
                    Method      = 'Patch'
                    Body        = @{
                        add = @{
                            windows = @{
                                files = @(
                                    @{
                                        pathvariable = 'pathvariable'
                                        path         = 'path'
                                        scheduled    = 'scheduled'
                                        features     = 'features'
                                    }
                                )
                            }
                        }
                    }
                    Query       = ''
                    Result      = ''
                    Success     = ''
                    Function    = 'Update-AllowListPolicyByFileName'
                    ObjectTName = 'SEPCloud.update-policy-response'
                }
            }
            Mock Get-SEPCloudPolicesSummary -ModuleName $ProjectName -MockWith {
                return @(
                    @{
                        name           = "Allow list policy 1"
                        author         = "Test User"
                        policy_uid     = '12345678-1234-1234-1234-123456789123'
                        policy_version = '1'
                        policy_type    = "Allow List"
                        is_imported    = $false
                        locked         = $true
                        created        = "2019-08-31T16:47:58.000Z"
                        modified       = "2019-08-31T16:47:58.000Z"
                    },
                    @{
                        name           = "Allow list policy 2"
                        author         = "Test User"
                        policy_uid     = '12345678-1234-1234-1234-123456789321'
                        policy_version = '2'
                        policy_type    = "Allow List"
                        is_imported    = $false
                        locked         = $true
                        created        = "2019-07-31T16:47:58.000Z"
                        modified       = "2019-07-31T16:47:58.000Z"
                    }
                )
            }
            Mock Submit-Request -ModuleName $ProjectName -MockWith {
                param ($uri, $header, $method, $body)
                @{
                    name           = "Allow list policy 1"
                    author         = "Test User"
                    policy_uid     = '12345678-1234-1234-1234-123456789123'
                    policy_version = '1'
                    policy_type    = "Allow List"
                    is_imported    = $false
                    locked         = $true
                    created        = "2019-08-31T16:47:58.000Z"
                    modified       = "2019-08-31T16:47:58.000Z"
                }
            }
        }

        It 'Correctly set the JSON body for the request' {
            InModuleScope $ProjectName {
                # Arrange
                $expectedJson = @{
                    add = @{
                        windows = @{
                            files = @(
                                @{
                                    pathvariable = '[NONE]'
                                    path         = 'C:\test\exception.exe'
                                    scheduled    = $true
                                    features     = @('AUTO_PROTECT', 'BEHAVIORAL_ANALYSIS')
                                }
                            )
                        }
                    }
                            } | Update-AllowListPolicyByFileName

                $expectedQuery = @{
                    name           = "Allow list policy 1"
                    author         = "Test User"
                    policy_uid     = '12345678-1234-1234-1234-123456789123'
                    policy_version = '1'
                    policy_type    = "Allow List"
                    is_imported    = $false
                    locked         = $true
                    created        = "2019-08-31T16:47:58.000Z"
                    modified       = "2019-08-31T16:47:58.000Z"
                }

                $result = Update-AllowListPolicyByFileName -policy_uid '12345678-1234-1234-1234-123456789123' -version '1' -path 'C:\test\exception.exe' -features @('AUTO_PROTECT', 'BEHAVIORAL_ANALYSIS')
                $body = $script:submitRequestParams[0].Body | ConvertTo-Json -Depth 100
                $body | Should -BeExactly $expectedJson
                $result | Should -BeLike $expectedQuery
            }
        }
    }
}
