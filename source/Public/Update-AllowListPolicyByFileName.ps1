function Update-AllowListPolicyByFileName {
    <#
    .SYNOPSIS
    Add a filename to the allow list policy.

    .DESCRIPTION
    Add a filename to the allow list policy.
    By default enable the exception of scheduled & manual scans for AutoProtect & Behavioral Analysis technologies

    .EXAMPLE
    $featuresList = @("AUTO_PROTECT", "BEHAVIORAL_ANALYSIS", "TAMPER_PROTECTION", "DEVICE_CONTROL", "ADAPTIVE_ISOLATION")
    Update-AllowListPolicyByFileName -policy_uid "12345678-1234-1234-1234-123456789123" -version "1" -path "C:\test\exception.exe" -features $featuresList

    adds file exception "C:\test\exception.exe" to the allow list policy with all the supported features

    .EXAMPLE
    $featuresList = @("AUTO_PROTECT", "BEHAVIORAL_ANALYSIS", "TAMPER_PROTECTION", "DEVICE_CONTROL", "ADAPTIVE_ISOLATION")
    Update-AllowListPolicyByFileName -policy_uid "12345678-1234-1234-1234-123456789123" -path "C:\test\exception.exe" -features $featuresList

    adds file exception "C:\test\exception.exe" to the allow list policy with all the supported features
    This time no version is provided, by default the latest version is used
    #>
    param (
        $policy_uid,
        $version,

        [Parameter()]
        [String]
        [ValidateSet(
            "[NONE]",
            "[COMMON_APPDATA]",
            "[COMMON_DESKTOPDIRECTORY]",
            "[COMMON_DOCUMENTS]",
            "[COMMON_PROGRAMS]",
            "[COMMON_STARTUP]",
            "[PROGRAM_FILES]",
            "[PROGRAM_FILES_COMMON]",
            "[SYSTEM]",
            "[SYSTEM_DRIVE]",
            "[USER_PROFILE]",
            "[WINDOWS]"
        )]
        $pathvariable = "[NONE]",

        [Parameter(Mandatory = $true)]
        $path,

        [bool]
        $scheduled = $true,

        [array]
        [ValidateScript({
                foreach ($feature in $_) {
                    if ($_ -notin @("AUTO_PROTECT", "BEHAVIORAL_ANALYSIS", "TAMPER_PROTECTION", "DEVICE_CONTROL", "ADAPTIVE_ISOLATION")) {
                        throw [System.Management.Automation.ValidationMetadataException] "Invalid feature: $feature"
                    }
                }
                return $true
            })]
        $features = @("AUTO_PROTECT", "BEHAVIORAL_ANALYSIS")
    )

    begin {
        # Check to ensure that a session to the SaaS exists and load the needed header data for authentication
        Test-SEPCloudConnection | Out-Null

        # API data references the name of the function
        # For convenience, that name is saved here to $function
        $function = $MyInvocation.MyCommand.Name

        # Retrieve all of the URI, method, body, query, result, and success details for the API endpoint
        Write-Verbose -Message "Gather API Data for $function"
        $resources = Get-SEPCLoudAPIData -endpoint $function
        Write-Verbose -Message "Load API data for $($resources.Function)"
        Write-Verbose -Message "Description: $($resources.Description)"
    }

    process {
        # Gets the latest policy version if no version is provided
        if ($null -eq $version) {
            $version = Get-SEPCloudPolicesSummary | Where-Object { $_.policy_uid -eq $policy_uid } | Select-Object -ExpandProperty policy_version
            Write-Verbose -Message "No version provided, using latest policy version : $version"
        }

        $uri = New-URIString -endpoint ($resources.URI) -id @($policy_uid, $version)
        $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri

        # Dynamically extract parameter values
        $paramsHash = @{}
        foreach ($param in (Get-Command $function).Parameters.Values) {
            $paramsHash[$param.Name] = (Get-Variable -Name $param.Name -ErrorAction 'SilentlyContinue').Value
        }

        # Dynamically build the body based on the --nested-- structure provided in $resources.Body
        $body = New-NestedBodyString -bodyStructure $resources.Body -parameterValues $paramsHash
        Write-Verbose -Message "Body is $(ConvertTo-Json -Depth 100 -InputObject $body)"

        $result = Submit-Request -uri $uri -header $script:SEPCloudConnection.header -method $($resources.Method) -body $body
        $result = Test-ReturnFormat -result $result -location $resources.Result
        $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result

        return $result
    }
}
