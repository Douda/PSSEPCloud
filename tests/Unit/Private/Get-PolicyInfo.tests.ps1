$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
    }).BaseName


Import-Module $ProjectName

InModuleScope $ProjectName {
    Describe 'Get-PolicyInfo' {
        It 'should retrieve policy_uid and version when policy_name is provided' {
            # Arrange
            $policy_name = 'TestPolicy'
            $expected_policy_uid = '12345'
            $expected_version = 2

            Mock Get-SEPCloudPolicesSummary {
                return @(
                    @{
                        name           = 'TestPolicy'
                        policy_uid     = $expected_policy_uid
                        policy_version = $expected_version
                    }
                )
            }

            $result = Get-PolicyInfo -policy_name $policy_name
            $result.policy_name | Should -Be $policy_name
            $result.policy_uid | Should -Be $expected_policy_uid
            $result.version | Should -Be $expected_version
        }

        It 'should retrieve version when policy_uid is provided' {
            # Arrange
            $policy_uid = '12345'
            $expected_version = 1

            Mock Get-SEPCloudPolicesSummary {
                return @(
                    @{
                        policy_uid     = $policy_uid;
                        policy_version = $expected_version
                    }
                )
            }

            $result = Get-PolicyInfo -policy_uid $policy_uid
            $result.policy_uid | Should -Be $policy_uid
            $result.version | Should -Be $expected_version
        }

        It 'should return provided policy_name and version when both are provided' {
            $policy_name = 'TestPolicy'
            $policy_uid = '12345'
            $version = 1

            $result = Get-PolicyInfo -policy_name $policy_name -policy_uid $policy_uid -version $version
            $result.policy_name | Should -Be $policy_name
            $result.policy_uid | Should -Be $policy_uid
            $result.version | Should -Be $version
        }
    }
}
