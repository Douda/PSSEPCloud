function Get-SEPCloudEDRDumpsList
{

    <#
        .SYNOPSIS
            Gets a list of the SEP Cloud Commands
        .DESCRIPTION
            Gets a list of the SEP Cloud Commands. All commands are returned by default.
        .LINK
            https://github.com/Douda/PSSymantecCloud
        .PARAMETER query
        Query to be used in the search
        Uses Lucene syntax.
        Is optional. If not used returns all commands by default
        .PARAMETER next
        The next page of results. Used for pagination
        .PARAMETER limit
        The maximum number of results returned. Used for pagination
        default is 25
        .EXAMPLE
            Get-SEPCloudCommand

            Gets a list of the SEP Cloud Commands
    #>

    [CmdletBinding()]
    Param(
        $next,
        $limit = 25,
        $query
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
        $uri = New-URIString -endpoint ($resources.URI) -id $id
        $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
        $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
        $result = Submit-Request -uri $uri -header $script:SEPCloudConnection.header -method $($resources.Method) -body $body

        # Test if pagination required
        if ($result.total -gt $result.commands.count)
        {
            Write-Verbose -Message "Result limits hit. Retrieving remaining data based on pagination"
            do
            {
                # Update offset/next query param for pagination
                $next = $result.next
                $uri = New-URIString -endpoint ($resources.URI) -id $id
                $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
                $nextResult = Submit-Request  -uri $uri  -header $script:SEPCloudConnection.header  -method $($resources.Method) -body $body
                $result.commands += $nextResult.commands
            } until ($result.commands.count -ge $result.total)
        }

        $result = Test-ReturnFormat -result $result -location $resources.Result
        $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result

        return $result
    }
}
