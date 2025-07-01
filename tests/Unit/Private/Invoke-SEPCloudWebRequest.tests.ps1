$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
    }).BaseName


Import-Module $ProjectName

InModuleScope $ProjectName {
    Describe Invoke-SEPCloudWebRequest {
        Context 'Default' {
            BeforeEach {
                $command = Get-Command -Name 'Invoke-SEPCloudWebRequest' -ErrorAction SilentlyContinue
            }

            It 'Should exist' { $command | Should -Not -BeNullOrEmpty }

            It 'Should be a function' { $command.CommandType | Should -Be 'Function' }
        }
    }
}


