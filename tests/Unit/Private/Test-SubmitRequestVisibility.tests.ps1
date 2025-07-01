BeforeAll {
    $module = Get-Module -ListAvailable -Name PSSEPCloud -RequiredVersion 0.0.1 | Select-Object -First 1
    Import-Module -Module $module -Force -ErrorAction Stop
}

Describe "Submit-Request Visibility" {
    It "should be discoverable" {
        { Get-Command Submit-Request } | Should -Not -Throw
    }

    It "should be callable" {
        { Submit-Request } | Should -Not -Throw
    }
}