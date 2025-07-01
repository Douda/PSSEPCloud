BeforeAll {
    $script:moduleName = 'PSSEPCloud'

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:moduleName

    Mock -CommandName Submit-Request -MockWith { return "Mocked Response" }
    Mock -CommandName Test-SEPCloudConnection -MockWith { return $true }
    Mock -CommandName Get-SEPCloudAPIData -MockWith { return @{ URI = "test"; Method = "POST"; ObjectTName = "TestObject" } }
}

AfterAll {
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    Remove-Module -Name $script:moduleName
}

Describe Block-SEPCloudFile {
