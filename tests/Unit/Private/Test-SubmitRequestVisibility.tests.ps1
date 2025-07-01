BeforeAll {
    Import-Module -Name PSSEPCloud -RequiredVersion 0.0.1 -Module (Join-Path $PSScriptRoot "../../../output/module/PSSEPCloud/0.0.1") -Force -ErrorAction Stop
}

Describe "Submit-Request Visibility" {
    It "should be discoverable" {
        { Get-Command Submit-Request } | Should -Not -Throw
    }

    It "should be callable" {
        { Submit-Request } | Should -Not -Throw
    }
}