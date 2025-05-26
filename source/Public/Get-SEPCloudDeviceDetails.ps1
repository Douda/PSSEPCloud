function Get-SEPCloudDeviceDetails
{

    <#
    .SYNOPSIS
        Gathers device details from the SEP Cloud console
    .DESCRIPTION
        Gathers device details from the SEP Cloud console
    .LINK
        https://github.com/Douda/PSSymantecCloud
    .PARAMETER device_id
        id used to lookup a unique computer
    .OUTPUTS
        PSObject
    .EXAMPLE
        Get-SepCloudDeviceDetails -id wduiKXDDSr2CVrRaqrFKNx

    #>

    [CmdletBinding()]
    Param(
        [Parameter(
            ValueFromPipelineByPropertyName = $true,
            ValueFromPipeline = $true)]
        [Alias("id")]
        [string]
        $device_id
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
        $uri = New-URIString -endpoint ($resources.URI) -id $device_id
        $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
        $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
        $result = Submit-Request -uri $uri -header $script:SEPCloudConnection.header -method $($resources.Method) -body $body
        $result = Test-ReturnFormat -result $result -location $resources.Result
        $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result
        return $result
    }
}
