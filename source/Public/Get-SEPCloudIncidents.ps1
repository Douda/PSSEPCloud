function Get-SEPCloudIncidents
{

    <#
    .SYNOPSIS
        Get list of SEP Cloud incidents
    .DESCRIPTION
        Get list of SEP Cloud incidents.
        Using the LUCENE query syntax, you can customize which incidents to gather.
    .PARAMETER start_date
        This value identifies the beginning date to filter incidents.
        The value should follow ISO 8601 date stamp standard format: yyyy-MM-dd’T’HH:mm:ss.SSSZ.
        Start date cannot be older than 30 days
    .PARAMETER end_date
        This value identifies the end date to filter incidents
        By default is thee time of the query (Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffK")
        The value should follow ISO 8601 date stamp standard format: yyyy-MM-dd’T’HH:mm:ss.SSSZ.
    .PARAMETER limit
        Maximum number of results per page (default is 15)
        Maximum allowed page size is 2000
    .PARAMETER next
        This value represents the starting index of the record in a given set.This is used for pagination
        If used, first request should always start with 0. If the response has next parameter set, request should be repeated with that next value
    .PARAMETER Include_events
        Includes every events that both are part of the context & triggered incident events
    .PARAMETER Query
        Custom Lucene query to pass to the API
        example: (state_id: 1 OR state_id: 4 )
        Details on syntax : https://techdocs.broadcom.com/us/en/symantec-security-software/endpoint-security-and-management/endpoint-security/sescloud/Alerts-and-Events/investigation-page-overview-v134374740-d38e87486/query-and-filter-operators-by-data-type-v134689952-d38e88796.html
    .INPUTS
        None
    .OUTPUTS
        PSObject containing all SEP incidents
    .EXAMPLE
        Get-SEPCloudIncidents -Include_Events
    .EXAMPLE
        Get-SEPCloudIncidents -Include_events -Query "state_id: [0 TO 3]"

        This query a list of every possible incidents (opened, closed and with "Unknown" status)
    .EXAMPLE
        $startDate = (Get-Date).AddDays(-7).ToString("yyyy-MM-ddTHH:mm:ss.fffK")
        Get-SEPCloudIncidents -start_date $startDate

        Get last 7 days incidents
    #>

    #>
    [CmdletBinding()]
    param (
        # Include events switch
        [switch]
        $Include_events,

        # Custom query to run
        [string]
        $Query,

        # pagination size
        [string] $limit,

        # next
        [string]$next,

        [string]$start_date,
        [string]$end_date = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffK")
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
        $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters  ((Get-Command $function).Parameters.Values)

        Write-Verbose -Message "Body is $(ConvertTo-Json -InputObject $body)"
        $result = Submit-Request -uri $uri -header $script:SEPCloudConnection.header -method $($resources.Method) -body $body

        # Test if pagination required
        if ($result.total -gt $result.incidents.count)
        {
            do
            {
                # Update next query param for pagination
                $next = $result.incidents.count
                $uri = New-URIString -endpoint ($resources.URI) -id $id
                $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
                $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters  ((Get-Command $function).Parameters.Values)
                $nextResult = Submit-Request  -uri $uri  -header $script:SEPCloudConnection.header  -method $($resources.Method) -body $body
                $result.incidents += $nextResult.incidents
            } until (
                ($result.incidents.count -ge $result.total)
            )
        }

        $result = Test-ReturnFormat -result $result -location $resources.Result
        $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result

        return $result
    }
}
