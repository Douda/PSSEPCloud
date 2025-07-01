BeforeAll {
    . "$PSScriptRoot/../../../source/Private/Submit-Request.ps1"
    Mock -CommandName Submit-Request -MockWith { return "Mocked Response" }
    Mock -CommandName Test-SEPCloudConnection -MockWith { return $true }
    Mock -CommandName Get-SEPCloudAPIData -MockWith { return @{ URI = "test"; Method = "POST"; ObjectTName = "TestObject" } }

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = 'PSSEPCloud'
    $PSDefaultParameterValues['Mock:ModuleName'] = 'PSSEPCloud'
    $PSDefaultParameterValues['Should:ModuleName'] = 'PSSEPCloud'
}

AfterAll {
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    Remove-Module -Name $script:moduleName
}

Describe Block-SEPCloudFile {
