BeforeAll {
    Mock -CommandName Invoke-SEPCloudWebRequest -MockWith { return "Mocked Web Request" }
    Mock -CommandName New-QueryURI -MockWith { return "Mocked URI" }
}

Describe "Submit-Request Visibility" {
    It "should be discoverable" {
        { Get-Command Submit-Request } | Should -Not -Throw
    }

    It "should be callable" {
        { Submit-Request } | Should -Not -Throw
    }
}