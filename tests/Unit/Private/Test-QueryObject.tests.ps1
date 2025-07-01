$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
    }).BaseName


Import-Module $ProjectName

InModuleScope $ProjectName {
    Describe Test-QueryObject {
        Context 'Default' {
            BeforeEach {
                $command = Get-Command -Name 'Test-QueryObject' -ErrorAction SilentlyContinue
            }

            It 'Should exist' { $command | Should -Not -BeNullOrEmpty }

            It 'Should be a function' { $command.CommandType | Should -Be 'Function' }
        }
    }
}


