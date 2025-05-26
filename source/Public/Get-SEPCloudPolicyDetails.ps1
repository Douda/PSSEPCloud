function Get-SepCloudPolicyDetails
{

    <#
    .SYNOPSIS
        Gathers detailed information on SEP Cloud policy
    .DESCRIPTION
        Gathers detailed information on SEP Cloud policy
    .PARAMETER policy_uid
        policy_uid
    .PARAMETER policyVersion
        Policy version
    .OUTPUTS
        PSObject
    .EXAMPLE
    Get-SepCloudPolicyDetails -policy_uid "12677e90-3909-4e8a-9f4a-327242269a13" -version 1
    #>

    [CmdletBinding()]
    Param(
        # {param details}
        [String]$policy_uid,
        # {param details}
        [String]$version
    )

    begin
    {
        # Check to ensure that a session to the SaaS exists and load the needed header data for authentication
        Test-SEPCloudConnection | Out-Null

        # API data references the name of the function
        # For convenience, that name is saved here to $function
        $function = $MyInvocation.MyCommand.Name

        # Retrieve all of the URI, method, body, query, result, and success details for the API endpoint
        Write-Verbose -Message "Gather API Data for $function"
        $resources = Get-SEPCloudAPIData -endpoint $function
        Write-Verbose -Message "Load API data for $($resources.Function)"
        Write-Verbose -Message "Description: $($resources.Description)"
    }

    process
    {
        # adding accept json header  otherwise binary stream
        $script:SEPCloudConnection.header += @{ 'Accept' = 'application/json' }

        $uri = New-URIString -endpoint ($resources.URI) -id @($policy_uid, $version)
        $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
        $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
        $result = Submit-Request -uri $uri -header $script:SEPCloudConnection.header -method $($resources.Method) -body $body
        $result = Test-ReturnFormat -result $result -location $resources.Result
        $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result

        # Removing "Content-Type: application/json" header
        $script:SEPCloudConnection.header.remove('Accept')

        return $result
    }
}
