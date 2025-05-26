function Get-SEPCloudThreatIntelFileProcessChain
{

    <#
    .SYNOPSIS
        Provide topK process lineage enrichment for the provided file sha256.
    .DESCRIPTION
        Provide topK process lineage enrichment for the provided file sha256.
    .INPUTS
        sha256
    .LINK
        https://github.com/Douda/PSSymantecCloud
    .OUTPUTS
        PSObject
    .PARAMETER file_sha256
        Specify one or many sha256 hash
    .EXAMPLE
        PS C:\PSSymantecCloud> $ProcessChain =  Get-SEPCloudThreatIntelFileProcessChain -file_sha256 eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d

        file                                                             chain
        ----                                                             -----
        eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d {@{parent=}}

        PS C:\PSSymantecCloud> $ProcessChain.chain

        parent
        ------
        @{parent=; file=18bba9ff311154415404e2fb16f3784e4c82b57ad110092ea5f9b76ed549e7cb; processName=fe392ea0a9f14s4dfeda8d9u0233a6ioq6e47a5n3.exe}

        .EXAMPLE
        "eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d" | Get-SEPCloudThreatIntelFileProcessChain
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
