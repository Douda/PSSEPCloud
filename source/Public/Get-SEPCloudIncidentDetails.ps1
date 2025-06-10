function Get-SEPCloudIncidentDetails
{

    <#
        .SYNOPSIS
        Gathers details about an open incident
        .DESCRIPTION
        Gathers details about an open incident
        .LINK
        https://github.com/Douda/PSSymantecCloud
        .PARAMETER incidentId
            ID of incident
        .EXAMPLE
        Get-SEPCloudIncidentDetails -incident_ID "21b23af2-ea44-479c-a235-9540082da98f"


    #>

    [CmdletBinding()]
    Param(
        # Query
        [Alias('incident_id')]
        [String]$incidentId
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
        $uri = New-URIString -endpoint ($resources.URI) -id $incidentId
        $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
        $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)

        Write-Verbose -Message "Body is $(ConvertTo-Json -InputObject $body)"
        $result = Submit-Request -uri $uri -header $script:SEPCloudConnection.header -method $($resources.Method) -body $body
        $result = Test-ReturnFormat -result $result -location $resources.Result
        $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result

        return $result
    }
}
