function Get-SEPCloudPolicesSummary
{

    <#
    .SYNOPSIS
        Provides a list of all SEP Cloud policies
    .DESCRIPTION
        Provides a list of all SEP Cloud policies
    .LINK
        https://github.com/Douda/PSSymantecCloud
    .PARAMETER limit
        The number of records fetched in a given request .
        [NOTE] The maximum number of records supported per request is 1000
    .PARAMETER offset
        When this field is not present, it returns the first page
    .PARAMETER name
        The name of the policy you want to search for
    .PARAMETER type
        The type of policy you want to search for
    .EXAMPLE
        Get-SEPCloudPolicesSummary
        Gathers all possible policies in your SEP Cloud account
    .EXAMPLE
        Get-SEPCloudPolicesSummary -name "My Exploit Protection Policy"

        name           : My Exploit Protection Policy
        author         : Imported from SEPM
        policy_uid     : abcdef123-abcd-5678-1234-123456789012
        policy_version : 1
        policy_type    : Exploit Protection
        is_imported    : True
        locked         : True
        created        : 28/06/2024 11:33:45
        modified       : 28/06/2024 11:33:45

        Gathers a summary of your specific policy
    .EXAMPLE
        Get-SEPCloudPolicesSummary -type "Exploit Protection"

        Gathers all Exploit Protection policies from your tenant
    #>

    [CmdletBinding()]
    param (
        $limit, # Defaults maximum limit is 1000
        $offset,
        $name,
        $type
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
        $resources = Get-SEPCLoudAPIData -endpoint $function
        Write-Verbose -Message "Load API data for $($resources.Function)"
        Write-Verbose -Message "Description: $($resources.Description)"
    }

    process
    {
        $uri = New-URIString -endpoint ($resources.URI) -id $id
        $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
        $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)

        Write-Verbose -Message "Body is $(ConvertTo-Json -InputObject $body)"
        $result = Submit-Request -uri $uri -header $script:SEPCloudConnection.header -method $($resources.Method) -body $body

        # Test if pagination required
        if ($result.total -gt $result.policies.count)
        {
            Write-Verbose -Message "Result limits hit. Retrieving remaining data based on pagination"
            do
            {
                # Update offset query param for pagination
                $offset = $result.policies.count
                $uri = New-URIString -endpoint ($resources.URI) -id $id
                $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
                $nextResult = Submit-Request  -uri $uri  -header $script:SEPCloudConnection.header  -method $($resources.Method) -body $body
                $result.policies += $nextResult.policies
            } until ($result.policies.count -ge $result.total)
        }

        $result = Test-ReturnFormat -result $result -location $resources.Result
        $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result

        return $result
    }
}
