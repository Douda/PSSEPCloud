$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
    }).BaseName

Import-Module $ProjectName

InModuleScope $ProjectName {
    Describe 'New-NestedBodyString' {
        Context 'Handling nested structures' {
            It 'Correctly builds a nested structure' {
                # Example of nested structure from Update-AllowListPolicyByFileName
                $bodyStructure = @{
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

                $parameterValues = @{
                    pathvariable = '[NONE]'
                    path         = 'C:\test\exception.exe'
                    scheduled    = $true
                    features     = @('AUTO_PROTECT', 'BEHAVIORAL_ANALYSIS')
                }

                $expectedBody = @{
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
                }

                $result = New-NestedBodyString -bodyStructure $bodyStructure -parameterValues $parameterValues
                $result | Should -BeLike $expectedBody
            }
        }
    }
}
