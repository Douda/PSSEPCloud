function Update-AllowListPolicyByFileHash {
    <#
    .SYNOPSIS
    Add a process exception to the allow list policy.

    .DESCRIPTION
    Add a process exception to the allow list policy.

    .EXAMPLE
    Update-AllowListPolicyByFileHash -policy_name "My Allow List Policy" -sha2 "366F3DF4774625375BCA2F4D4BEA118A0F661105B09B71219DBF79CBFB5E17B8" -name "test.exe"

    adds file exception "test.exe" to the latest version of the allow list policy "My Allow List Policy"

    .PARAMETER policy_name
    The name of the allow list policy

    .PARAMETER sha2
    The SHA-256 hash of the file

    .PARAMETER name
    The name of the file
    #>
    [CmdletBinding()]
    param (
        $policy_uid,
        $version,
        $policy_name,

        [ValidateScript({
                if ($_ -match '^[0-9a-fA-F]{64}$') {
                    return $true
                } else {
                    throw "Invalid SHA-256 hash. The hash must be a 64-character hexadecimal string."
                }
            })]
        [Parameter(Mandatory = $true)]
        $sha2,

        $name
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
        # Get policy information
        $policyInfo = Get-PolicyInfo -policy_name $policy_name -policy_uid $policy_uid -version $version
        $policy_uid = $policyInfo.policy_uid
        $version = $policyInfo.version

        # Build the URI
        $uri = New-URIString -endpoint ($resources.URI) -id @($policy_uid, $version)
        $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri

        # Dynamically extract parameter values to build nested body structure
        $paramsHash = Get-ParameterValuesAsHashtable -functionName $function
        $body = New-NestedBodyString -bodyStructure ($resources.Body) -parameterValues $paramsHash

        # Submit the request & format the result
        $result = Submit-Request -uri $uri -header $script:SEPCloudConnection.header -method $($resources.Method) -body $body
        $result = Test-ReturnFormat -result $result -location $resources.Result
        $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result

        return $result
    }
}
