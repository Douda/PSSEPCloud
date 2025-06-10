function Move-SEPCloudDevice
{

    <#
    .SYNOPSIS
        Moves one or many devices to a different group
    .DESCRIPTION
        Moves one or many devices to a different group.
        Requires group ID and device ID. does not support device name or group name.
        You can use :
            Get-SEPCloudDevice to get the device ID
            Get-SEPCloudGroup to get the group ID
    .LINK
        https://github.com/Douda/PSSymantecCloud
    .PARAMETER GroupID
        The group ID to move the device to
    .PARAMETER deviceId
        The device ID to move
        can be an array of device ID's
        [NOTE] maximum of 200 devices per call
    None
    .EXAMPLE
        Move-SEPCloudDevice -GroupID "tqrSman3RyqFFd1EqLlZZA" -DeviceID "f3teVmApQlya8XJvEf-wpw"

            Move-SEPCloudDevice -GroupID "tqrSman3RyqFFd1EqLlZZA" -DeviceID "f3teVmApQlya8XJvEf-wpw"

            device_uid             message            status
            ----------             -------            ------
            f3teVmApQlya8XJvEf-wpw Moved successfully MOVED

        Moves a device to a different group, returns the status of the move.
    .EXAMPLE
        $list = @('123', '456', '789')
        Move-SEPCloudDevice -groupId "I5tExK6hQfC-cnUXk1Siug" -deviceId $list

        Moves all devices from their identifier (here 123,456,789) to a group from a single API call
    #>

    [CmdletBinding()]
    Param(
        # Group ID
        [Parameter(
            ValueFromPipelineByPropertyName = $true
        )]
        $groupId,

        # Device ID
        [Parameter(
            ValueFromPipelineByPropertyName = $true,
            ValueFromPipeline = $true
        )]
        [Alias('device_uids')]
        [ValidateCount(1, 200)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $deviceId
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
        $uri = New-URIString -endpoint ($resources.URI) -id $groupId
        $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
        $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
        $result = Submit-Request -uri $uri -header $script:SEPCloudConnection.header -method $($resources.Method) -body $body
        $result = Test-ReturnFormat -result $result -location $resources.Result
        $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result
        return $result
    }
}
