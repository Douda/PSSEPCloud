function Start-SEPCloudDefinitionUpdate
{

    <#
    .SYNOPSIS
        Initiate a definition update request command on SEP Cloud managed devices
    .DESCRIPTION
        Initiate a definition update request command on SEP Cloud managed devices
    .PARAMETER device_ids
        Array of device ids for which to initiate a definition update request
    .EXAMPLE
        Start-SepCloudDefinitionUpdate -deviceId "u7IcxqPvQKmH47MPinPsFw"
    .LINK
        https://github.com/Douda/PSSymantecCloud
    #>

    [CmdletBinding()]
    Param(
        [Alias('deviceId')]
        [string[]]
        $device_ids,

        [string[]]
        [Alias('orgId')]
        $org_unit_ids,

        [Alias('recursive')]
        [switch]
        $is_recursive
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
        # TODO function is not working (500 error response)
        # changing "Content-Type" header specifically for this query, otherwise 415 : unsupported media type
        # $script:SEPCloudConnection.header += @{ 'Content-Type' = 'application/json' }
        $script:SEPCloudConnection.header += @{ 'Accept' = 'application/json' }

        $uri = New-URIString -endpoint ($resources.URI) -id $id
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
