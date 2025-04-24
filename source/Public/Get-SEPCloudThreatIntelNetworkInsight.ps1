function Get-SEPCloudThreatIntelNetworkInsight
{

    <#
    .SYNOPSIS
        Provide domain insight enrichments for a given domain
    .DESCRIPTION
        Provide domain insight enrichments for a given domain
    .INPUTS
        domain
    .OUTPUTS
        PSObject
    .LINK
        https://github.com/Douda/PSSymantecCloud
    .PARAMETER domain
        Specify one or many domain
    .EXAMPLE
        PS C:\PSSymantecCloud> Get-SepThreatIntelNetworkInsight -domain "elblogdeloscachanillas.com.mx/s3sy8rq10/ophn.png"

        network         : elblogdeloscachanillas.com.mx/s3sy8rq10/ophn.png
        threatRiskLevel : @{level=10}
        categorization  : @{categories=System.Object[]}
        reputation      : BAD
        targetOrgs      : @{topCountries=System.Object[]; topIndustries=System.Object[]}
    .EXAMPLE
    "elblogdeloscachanillas.com.mx/s3sy8rq10/ophn.png" | Get-SepThreatIntelNetworkInsight
    #>

    [CmdletBinding()]
    Param(
        # Mandatory domain
        [Parameter(
            Mandatory,
            ValueFromPipeline = $true)]
        [Alias('URL')]
        $domain
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
        $uri = New-URIString -endpoint ($resources.URI) -id $domain
        $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
        $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)

        Write-Verbose -Message "Body is $(ConvertTo-Json -InputObject $body)"
        $result = Submit-Request -uri $uri -header $script:SEPCloudConnection.header -method $($resources.Method) -body $body

        $result = Test-ReturnFormat -result $result -location $resources.Result
        $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result

        return $result
    }
}
