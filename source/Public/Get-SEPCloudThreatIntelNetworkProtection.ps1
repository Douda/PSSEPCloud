function Get-SEPCloudThreatIntelNetworkProtection
{

    <#
    .SYNOPSIS
        Provide information whether a given URL/domain has been blocked by any of Symantec technologies
    .DESCRIPTION
        Provide information whether a given URL/domain has been blocked by any of Symantec technologies.
        These technologies include Antivirus (AV), Intrusion Prevention System (IPS) and Behavioral Analysis & System Heuristics (BASH)
    .PARAMETER domain
        Specify one or many URL/domain to check
    .LINK
        https://github.com/Douda/PSSymantecCloud
    .OUTPUTS
        PSObject
    .EXAMPLE
        Get-SepThreatIntelNetworkProtection -domain nicolascoolman.eu
        Gathers information whether the URL/domain has been blocked by any of Symantec technologies
    .EXAMPLE
        "nicolascoolman.eu" | Get-SepThreatIntelNetworkProtection
        Gathers somains from pipeline by value whether the URLs/domains have been blocked by any of Symantec technologies
    #>

    [CmdletBinding()]
    param (
        # Mandatory domain name
        [Parameter(
            Mandatory,
            ValueFromPipeline = $true)]
        [Alias('domain', 'url')]
        $network
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
        $uri = New-URIString -endpoint ($resources.URI) -id $network
        $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
        $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)

        Write-Verbose -Message "Body is $(ConvertTo-Json -InputObject $body)"
        $result = Submit-Request -uri $uri -header $script:SEPCloudConnection.header -method $($resources.Method) -body $body

        $result = Test-ReturnFormat -result $result -location $resources.Result
        $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result

        return $result
    }
}
