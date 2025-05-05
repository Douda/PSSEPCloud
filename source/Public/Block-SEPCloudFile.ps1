function Block-SEPCloudFile
{

    <#
    .SYNOPSIS
        Quarantines one or many files on one or many SEP Cloud managed endpoint
    .DESCRIPTION
        Quarantines one or many files on one or many SEP Cloud managed endpoint
    .PARAMETER device_ids
        The ID of the SEP Cloud managed endpoint to quarantine file(s) from
    .PARAMETER hash
        hash of the file to quarantine
    .LINK
        https://github.com/Douda/PSSymantecCloud
    .EXAMPLE
        Block-SEPCloudFile -Verbose -device_ids "dGKQS2SyQlCbPjC2VxqO0w" -hash "C4C3115E3A1AF01D6747401AA22AF90A047292B64C4EEFF4D8021CC0CB60B22D"

        BLocks a specific file on a specific computer by its device_id and hash
    #>

    [CmdletBinding()]
    # Suppress the unused parameter warning for the parameters that are not used in this function
    # They are used via BodyString & URIString functions
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "")]
    Param(
        [Alias('deviceId')]
        [String[]]
        $device_ids,

        [Alias('sha256')]
        [String[]]
        $hash
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
        # changing "Host" header specifically for this query, otherwise 500
        $script:SEPCloudConnection.header += @{ 'Host' = $script:SEPCloudConnection.BaseURL }

        $uri = New-URIString -endpoint ($resources.URI) -id $id
        $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
        $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
        $result = Submit-Request -uri $uri -header $script:SEPCloudConnection.header -method $($resources.Method) -body $body
        $result = Test-ReturnFormat -result $result -location $resources.Result
        $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result

        # removing the "Host" header specifically for this query, otherwise 500
        $script:SEPCloudConnection.header.remove('Host')

        return $result
    }
}
