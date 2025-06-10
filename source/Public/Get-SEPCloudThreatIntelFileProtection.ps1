function Get-SEPCloudThreatIntelFileProtection
{

    <#
    .SYNOPSIS
        Provide information whether a given file has been blocked by any of Symantec technologies
    .DESCRIPTION
        Provide information whether a given file has been blocked by any of Symantec technologies.
        These technologies include Antivirus (AV), Intrusion Prevention System (IPS) and Behavioral Analysis & System Heuristics (BASH)
    .INPUTS
        sha256
    .OUTPUTS
        PSObject
    .LINK
        https://github.com/Douda/PSSymantecCloud
    .PARAMETER file_sha256
        Specify one or many sha256 hash
    .EXAMPLE
        Get-SepThreatIntelFileProtection -file_sha256 eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d
        Gathers information whether the file with sha256 has been blocked by any of Symantec technologies
    .EXAMPLE
        "eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d","eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8e" | Get-SepThreatIntelFileProtection
        Gathers sha from pipeline by value whether the files with sha256 have been blocked by any of Symantec technologies
    #>

    [CmdletBinding()]
    Param(
        # Mandatory file sha256
        [Parameter(
            Mandatory,
            ValueFromPipeline = $true)]
        [Alias('sha256')]
        $file_sha256
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
        $uri = New-URIString -endpoint ($resources.URI) -id $file_sha256
        $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
        $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)

        Write-Verbose -Message "Body is $(ConvertTo-Json -InputObject $body)"
        $result = Submit-Request -uri $uri -header $script:SEPCloudConnection.header -method $($resources.Method) -body $body

        $result = Test-ReturnFormat -result $result -location $resources.Result
        $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result

        return $result
    }
}
