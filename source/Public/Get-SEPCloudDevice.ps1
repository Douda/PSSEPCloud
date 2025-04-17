function Get-SEPCloudDevice
{
    <#
    .SYNOPSIS
    Gathers list of devices from the SEP Cloud console
    .DESCRIPTION
    Gathers list of devices from the SEP Cloud console
    .PARAMETER client_version
    Version of agent installed on device.
    [NOTE] Provide comma seperated values in case of multiple version search.
    .PARAMETER device_group
    ID of the parent device group.
    [NOTE] Provide comma seperated values in case of multiple name search.
    .PARAMETER device_status
    Device status
    Possible values: SECURE,AT_RISK, COMPROMISED,NOT_COMPUTED
    [NOTE] Provide comma seperated values in case of multiple status search.
    .PARAMETER device_type
    os type of the device
    [NOTE] Provide comma seperated values in case of multiple os type search.
    Possible values: WORKSTATION, SERVER, MOBILE
    .PARAMETER name
    name of the device.
    [NOTE] Provide comma seperated values in case of multiple name search.
    .PARAMETER ipv4_address
    ipv4 address of a device.


    .EXAMPLE
    Get-SEPCloudDevice
    Get all devices (very slow)
    .EXAMPLE
    Get-SEPCloudDevice -Computername MyComputer
    Get detailed information about a computer
    .EXAMPLE
    Get-SEPCloudDevice -client_version "14.2.1031.0100,14.2.770.0000"
    Get all devices with client version 14.2.1031.0100 and 14.2.770.0000
    .EXAMPLE
    Get-SEPCloudDevice -device_group "Fmp5838YRsyElHM27PdZww,123456789"
    Get all devices from the 2 groups with the group IDs "Fmp5838YRsyElHM27PdZww" and "123456789
    .EXAMPLE
    Get-SEPCloudDevice -device_status AT_RISK
    Get all online devices with AT_RISK status
    .EXAMPLE
    Get-SEPCloudDevice -Client_version "14.3.9681.7000" -device_type WORKSTATION
    Get all workstations with client version 14.3.9681.7000
    .EXAMPLE
    Get-SEPCloudDevice -IPv4 "192.168.1.1"
    Get all devices with IPv4 address
    #>

    [CmdletBinding()]
    param (
        [Alias("ClientVersion")]
        $client_version,

        [Alias("Group")]
        $device_group,

        [Alias("DeviceStatus")]
        [ValidateSet("SECURE", "AT_RISK", "COMPROMISED", "NOT_COMPUTED")]
        $device_status,

        [Alias("DeviceType")]
        [ValidateSet("WORKSTATION", "SERVER", "MOBILE")]
        $device_type,

        [Alias("IPv4")]
        $ipv4_address,

        [Alias("computername")]
        $name,

        [switch]
        $is_virtual,

        $offset
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
        if ($result.total -gt $result.devices.count)
        {
            Write-Verbose -Message "Result limits hit. Retrieving remaining data based on pagination"
            do
            {
                # Update offset query param for pagination
                $offset = $result.devices.count
                $uri = New-URIString -endpoint ($resources.URI) -id $id
                $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
                $nextResult = Submit-Request  -uri $uri  -header $script:SEPCloudConnection.header  -method $($resources.Method) -body $body
                $result.devices += $nextResult.devices
            } until ($result.devices.count -ge $result.total)
        }

        $result = Test-ReturnFormat -result $result -location $resources.Result
        $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result

        return $result
    }
}
