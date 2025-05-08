BeforeAll {
    $script:moduleName = 'PSSEPCloud'

    # If the module is not found, run the build task 'noop'.
    if (-not (Get-Module -Name $script:moduleName -ListAvailable)) {
        # Redirect all streams to $null, except the error stream (stream 2)
        & "$PSScriptRoot/../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
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

Describe 'Update-AllowListPolicyByFileHash' {
    BeforeAll {
        # Arrange
        $sha2 = 'some-sha2'
        $name = 'some-name'
        $policy_name = 'some-policy-name'
        $version = 1

        $expectedBody = @{
            add = @{
                applications = @(
                    @{
                        processfile = @(
                            @{
                                sha2 = $sha2
                                name = $name
                            }
                        )
                    }
                )
            }
        }

        $submitRequestParams = @()
        Mock Submit-Request -ModuleName $script:moduleName -ParameterFilter {
            $body -eq $expectedBody
        } -MockWith {
            param ($body)
            $submitRequestParams += @{ body = $body }
            return @{
                policy_type    = 'Allow List'
                policy_version = 1
                policy_uid     = 'some-policy-uid'
                name           = 'some-policy-name'
            }
        }

        Mock Get-PolicyInfo -ModuleName $script:moduleName -MockWith {
            param ($policy_name, $version)
            return @{
                policy_name = 'some-policy-name'
                policy_uid  = 'some-policy-uid'
                version     = 1
            }
        }
    }

    Context 'When updating Allow List policy by file hash' {
        It 'should successfully update the policy' {
            $result = Update-AllowListPolicyByFileHash -Sha2 $sha2 -Name $name -policy_name $policy_name

            $result | Should -Not -BeNullOrEmpty
        }

        It 'should handle invalid input gracefully' {
            # Arrange
            $sha2 = 'some-sha2'
            $name = 'some-name'

            # Act & Assert
            { Update-AllowListPolicyByFileHash -Sha2 $sha2 -Name $name -policy_name $policy_name } | Should -Throw
        }
    }
}
