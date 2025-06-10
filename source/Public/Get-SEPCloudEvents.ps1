function Get-SEPCloudEvents
{
    <#
    .SYNOPSIS
        Get list of SEP Cloud Events. By default it will gather data for past 30 days
    .DESCRIPTION
        Get list of SEP Cloud Events. You can use the following parameters to filter the results: FileDetection, FullScan, or a custom Lucene query
    .LINK
        https://github.com/Douda/PSSymantecCloud
    .PARAMETER feature_name
        Filters events based on a product feature.
        [NOTE] ==== You can add a comma separated list of feature_name values
        (i.e. Agent Framework, Deception, Firewall) to define a unique set of events to search. ====
    .PARAMETER product
        The value is SAEP. This represents Symantec Endpoint Security events.
        [NOTE] ==== SAEP is the only available product value. ====
    .PARAMETER query
        A custom Lucene query to filter the results
        e.g. type_id:8001
    .PARAMETER start_date
        This value identifies the beginning date to filter events.
    .PARAMETER end_date
        This value identifies the ending date to filter events.
    .PARAMETER next
        represents the starting index of the record in a given set.This is used for pagination.
    .PARAMETER limit
        This value identifies batch size.This is also used for pagination.
    .EXAMPLE
        Get-SepCloudEvents
        Gather all possible events. ** very slow approach & limited to 10k events **
    .EXAMPLE
        Get-SepCloudEvents -Query "type_id:8031 OR type_id:8032 OR type_id:8033"
        Runs a custom Lucene query
    #>
    [CmdletBinding(DefaultParameterSetName = 'Query')]
    param (
        $feature_name = "ALL",
        $product = "SAEP",
        $query,
        $start_date = ((Get-Date).AddDays(-29) | Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffK"), # Default is 29 days ago
        $end_date = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffK"), # Default is today
        $next, # for pagination
        $limit = 1000 # Maximum number of results per page (API default = 100)
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
        $uri = New-URIString -endpoint ($resources.URI)
        $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
        $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)

        Write-Verbose -Message "Body is $(ConvertTo-Json -InputObject $body)"
        $result = Submit-Request -uri $uri -header $script:SEPCloudConnection.header -method $($resources.Method) -body $body

        # Test if pagination required
        if ($result.total -gt $result.events.count)
        {
            Write-Verbose -Message "Result limits hit. Retrieving remaining data based on pagination"
            do
            {
                # Update offset query param for pagination (called next)
                $next = $next + $result.next
                $uri = New-URIString -endpoint ($resources.URI)
                $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
                $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
                $nextResult = Submit-Request  -uri $uri  -header $script:SEPCloudConnection.header  -method $($resources.Method) -body $body
                $result.events += $nextResult.events
            } until ($result.events.count -ge $result.total)
        }

        $result = Test-ReturnFormat -result $result -location $resources.Result
        $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result

        return $result

    }
}
