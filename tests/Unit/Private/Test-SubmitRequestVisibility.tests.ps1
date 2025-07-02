BeforeAll {
    Import-Module -Name PSSEPCloud -Force -ErrorAction Stop
}

Describe "Submit-Request Visibility" {
    It "should be discoverable" {
        { Get-Command Submit-Request } | Should -Not -Throw
    }

    It "should be callable" {
        { Submit-Request } | Should -Not -Throw
    }
}