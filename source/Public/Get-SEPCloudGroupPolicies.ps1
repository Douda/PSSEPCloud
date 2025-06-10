function Get-SEPCloudGroupPolicies
{

    <#
        .SYNOPSIS
        Gathers list of policies applied for a device group
        .DESCRIPTION
        Gathers list of policies applied for a device group
        .LINK
        https://github.com/Douda/PSSymantecCloud
        .PARAMETER group_id
        id of device group
        .EXAMPLE
        Get-SEPCloudGroupPolicies -GroupID "Fmp5838YRsyElHM27PdZxx"
        Gets the list of every policies applied to a device group
    #>

    [CmdletBinding()]
    param (
        # Group ID
        [Parameter(
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('groupID')]
        [String]
        $group_id
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
        $uri = New-URIString -endpoint ($resources.URI) -id $group_id
        $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
        $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters  ((Get-Command $function).Parameters.Values)

        Write-Verbose -Message "Body is $(ConvertTo-Json -InputObject $body)"
        $result = Submit-Request -uri $uri -header $script:SEPCloudConnection.header -method $($resources.Method) -body $body
        $result = Test-ReturnFormat -result $result -location $resources.Result
        $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result

        return $result
    }
}
