BeforeAll {
    $script:moduleName = 'PSSEPCloud'
    $ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
    $ProjectName = (Get-ChildItem $ProjectPath\*\*.psd1 | Where-Object {
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
            $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false }) }
    ).BaseName

    # If the module is not found, run the build task 'noop'.
    if (-not (Get-Module -Name $script:moduleName -ListAvailable)) {
        # Redirect all streams to $null, except the error stream (stream 2)
        & "$PSScriptRoot/../../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
    }

    # Re-import the module using force to get any code changes between runs.
    Import-Module -Name $script:moduleName #-Force -ErrorAction 'Stop'

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:moduleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    Remove-Module -Name $script:moduleName
}

Describe 'Set-SEPCloudRegion' {
    Context 'Set correct region' {
        InModuleScope $ProjectName {

            It 'Sets the BaseURL for region <region>' -TestCases @(
                @{ region = 'North America'; ExpectedURL = 'api.sep.us.securitycloud.symantec.com' }
                @{ region = 'Europe'; ExpectedURL = 'api.sep.eu.securitycloud.symantec.com' }
                @{ region = 'India'; ExpectedURL = 'api.sep.in.securitycloud.symantec.com' }
            ) {
                param (
                    $region,
                    $ExpectedURL
                )

                Set-SEPCloudRegion -region $region
                $script:SEPCloudConnection.BaseURL | Should -Be $ExpectedURL
            }
        }
    }
}
