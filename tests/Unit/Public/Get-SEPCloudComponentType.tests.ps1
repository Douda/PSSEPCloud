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


Describe 'Get-SEPCloudComponentType' {
    BeforeAll {
        # Mock Private functions (requires -ModuleName for Pester v5)
        Mock Test-SEPCloudConnection -ModuleName $script:moduleName -MockWith { $true }
        Mock Submit-Request -ModuleName $script:moduleName -MockWith {
            return [PSCustomObject]@{
                total       = 1000
                total_count = 1000
                data        = @(1..1000)
            }
        }
    }

    Context 'Return values' {
        BeforeAll {}

        It 'Returns a list of objects' {
            $result = Get-SEPCloudComponentType -ComponentType "network-ips"
            ($result | Measure-Object).Count | Should -Be 1000
        }

        Context 'test subgroup types' {
            BeforeAll {}

            $testCases = @(
                @{ ComponentType = 'network-ips'; PSTypeName = "SEPCloud.ips_metadata"; sampleData = ([PSCustomObject]@{ classifications = "classifications" }) },
                @{ ComponentType = 'host-groups'; PSTypeName = "SEPCloud.host-group"; sampleData = ([PSCustomObject]@{ hosts = "hosts" }) },
                @{ ComponentType = 'network-adapters'; PSTypeName = "SEPCloud.adapter"; sampleData = ([PSCustomObject]@{ identification = "identification" }) },
                @{ ComponentType = 'network-services'; PSTypeName = "SEPCloud.network-services"; sampleData = ([PSCustomObject]@{ services = "services" }) }
            )

            It "Should return objects of type '<PSTypeName>' when ComponentType is '<ComponentType>'" -TestCases $testCases {
                param ($ComponentType, $PSTypeName, $sampleData)

                Mock Submit-Request -ModuleName $script:moduleName -ParameterFilter { $ComponentType -eq $ComponentType } -MockWith {
                    param ($ComponentType)

                    return [PSCustomObject]@{
                        total       = $data.Count
                        total_count = $data.Count
                        data        = $sampleData
                    }
                }

                $result = Get-SEPCloudComponentType -ComponentType $ComponentType
                $result.PSObject.TypeNames | Should -Contain $PSTypeName
            }
        }
    }

    Context 'Internal logic' {
        BeforeAll {
            # Initialize a variable to capture the parameters
            $script:submitRequestParams = @()

            Mock Submit-Request -ModuleName $script:moduleName -MockWith {
                param ($uri, $header, $method, $body)
                # Capture the parameters
                $script:submitRequestParams += [PSCustomObject]@{
                    Uri    = $uri
                    Header = $header
                    Method = $method
                    Body   = $body
                }

                # Return mock data
                return [PSCustomObject]@{
                    total       = 2000
                    total_count = 2000
                    data        = @(1..1000)
                }
            }
        }

        It 'hit pagination' {
            Get-SEPCloudComponentType -ComponentType "network-ips"
            Should -Invoke -CommandName Submit-Request -ModuleName $script:moduleName -Times 2
        }

        It 'correct pagination offsetting' {
            # Clear the captured parameters before the test
            $script:submitRequestParams = @()

            Get-SEPCloudComponentType -ComponentType "network-ips"

            # Check that Submit-Request was called twice
            $script:submitRequestParams.Count | Should -Be 2

            # Check the offset in the second call
            $secondCallUri = $script:submitRequestParams[1].Uri
            $secondCallOffset = [regex]::Match($secondCallUri, 'offset=(\d+)').Groups[1].Value
            $secondCallOffset | Should -Be 1000
        }
    }

}
