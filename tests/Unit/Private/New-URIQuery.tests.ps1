$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
    }).BaseName


Import-Module $ProjectName

InModuleScope $ProjectName {
    Describe New-URIQuery {
        Context 'Function structure and parameters' {
            It 'Should have required parameters' {
                $command = Get-Command -Name 'New-URIQuery' -ErrorAction SilentlyContinue
                $command | Should -Not -BeNullOrEmpty
                $command.Parameters.Keys | Should -Contain 'queryKeys'
                $command.Parameters.Keys | Should -Contain 'parameters'
                $command.Parameters.Keys | Should -Contain 'uri'
            }

            It 'Should support ShouldProcess' {
                $command = Get-Command -Name 'New-URIQuery'
                $command.Parameters.Keys | Should -Contain 'WhatIf'
                $command.Parameters.Keys | Should -Contain 'Confirm'
            }

            It 'Should support -WhatIf without throwing' {
                { New-URIQuery -queryKeys @() -parameters @() -uri 'https://example.com' -WhatIf } | Should -Not -Throw
            }

            It 'Should return expected URI when using -WhatIf' {
                $result = New-URIQuery -queryKeys @() -parameters @() -uri 'https://example.com' -WhatIf
                $result | Should -Be 'https://example.com'
            }
        }
    }
}

