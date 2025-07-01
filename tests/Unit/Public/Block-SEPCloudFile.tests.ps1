BeforeAll {
    Import-Module -Name PSSEPCloud -Function Submit-Request, Test-SEPCloudConnection, Get-SEPCloudAPIData -ErrorAction Stop
    Mock -CommandName Submit-Request -MockWith { return "Mocked Response" }
    Mock -CommandName Test-SEPCloudConnection -MockWith { return $true }
    Mock -CommandName Get-SEPCloudAPIData -MockWith { return @{ URI = "test"; Method = "POST"; ObjectTName = "TestObject" } }

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = 'PSSEPCloud'
    $PSDefaultParameterValues['Mock:ModuleName'] = 'PSSEPCloud'
    $PSDefaultParameterValues['Should:ModuleName'] = 'PSSEPCloud'

    Write-Host "Verifying module and function visibility:"
    Get-Module PSSEPCloud | Write-Host
    Get-Command Submit-Request | Write-Host
    Get-Command Test-SEPCloudConnection | Write-Host
    Get-Command Get-SEPCloudAPIData | Write-Host
}

AfterAll {
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    Remove-Module -Name 'PSSEPCloud'
}

Describe Block-SEPCloudFile {
