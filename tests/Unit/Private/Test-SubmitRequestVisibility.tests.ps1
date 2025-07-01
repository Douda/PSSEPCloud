BeforeAll {
    . "$PSScriptRoot/../../../source/Private/Submit-Request.ps1"
    . "$PSScriptRoot/../../../source/Private/Invoke-SEPCloudWebRequest.ps1"
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