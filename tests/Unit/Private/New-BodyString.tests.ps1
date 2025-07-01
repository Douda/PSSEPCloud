$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
    }).BaseName


Import-Module $ProjectName

InModuleScope $ProjectName {
    Describe New-BodyString {
        Context 'Function structure and parameters' {
            It 'Should have required parameters' {
                $command = Get-Command -Name 'New-BodyString' -ErrorAction SilentlyContinue
                $command | Should -Not -BeNullOrEmpty
                $command.Parameters.Keys | Should -Contain 'bodykeys'
                $command.Parameters.Keys | Should -Contain 'parameters'
            }

            It 'Should support ShouldProcess' {
                $command = Get-Command -Name 'New-BodyString'
                $command.Parameters.Keys | Should -Contain 'WhatIf'
                $command.Parameters.Keys | Should -Contain 'Confirm'
            }

            It 'Should support -WhatIf without throwing' {
                { New-BodyString -bodykeys @() -parameters @() -WhatIf } | Should -Not -Throw
            }

            It 'Should return null when using -WhatIf' {
                $result = New-BodyString -bodykeys @() -parameters @() -WhatIf
                $result | Should -BeNullOrEmpty
            }
        }
    }
}

