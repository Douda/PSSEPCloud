$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
    }).BaseName


Import-Module $ProjectName

InModuleScope $ProjectName {
    Describe 'Get-ParameterValuesAsHashtable' {
        Context 'When called with valid parameters' {
            It 'Correctly extracts parameter values' {
                # Define a test function with parameters
                function Test-Function {
                    param (
                        [string]$param1,
                        [int]$param2,
                        [bool]$param3
                    )
                    # This function is just for testing purposes
                }

                # Set the parameter values
                $param1 = 'value1'
                $param2 = 42
                $param3 = $true

                # Call the function to extract parameter values
                $result = Get-ParameterValuesAsHashtable -functionName 'Test-Function'

                # Define the expected result
                $expectedResult = @{
                    param1 = 'value1'
                    param2 = 42
                    param3 = $true
                }

                # Assert that the result matches the expected result
                $result | Should -BeLike $expectedResult
            }
        }

        Context 'When called with no parameters' {
            It 'Returns an empty hashtable' {
                # Define a test function with no parameters
                function Test-Function-NoParams {
                    # This function is just for testing purposes
                }

                # Call the function to extract parameter values
                $result = Get-ParameterValuesAsHashtable -functionName 'Test-Function-NoParams'

                # Define the expected result
                $expectedResult = @{}

                # Assert that the result matches the expected result
                $result | Should -BeLike $expectedResult
            }
        }

        Context 'When called with parameters that have default values' {
            It 'Correctly extracts parameter values including defaults' {
                # Define a test function with parameters and default values
                function Test-Function-WithDefaults {
                    param (
                        [string]$param1 = 'default1',
                        [int]$param2 = 100,
                        [bool]$param3 = $false
                    )
                    # This function is just for testing purposes
                }

                # Set the parameter values
                $param1 = 'value1'
                $param2 = 42
                $param3 = $true

                # Call the function to extract parameter values
                $result = Get-ParameterValuesAsHashtable -functionName 'Test-Function-WithDefaults'

                # Define the expected result
                $expectedResult = @{
                    param1 = 'default1'
                    param2 = 100
                    param3 = $false
                }

                # Assert that the result matches the expected result
                $result | Should -BeLike $expectedResult
            }
        }
    }
}
