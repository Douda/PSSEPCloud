function Get-SEPCloudComponentType {

    <#
    .SYNOPSIS
        This API lets you retrieve policy component host-groups, network-adapters(adapter), network-services(Connection), network IPS details
    .DESCRIPTION
        This API lets you retrieve policy component host-groups, network-adapters(adapter), network-services(Connection), network IPS details
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        https://github.com/Douda/PSSymantecCloud
    .EXAMPLE
        Get-SEPCloudComponentType -componentType 'network-adapters'

        Provides the full list of network adapters available on the cloud.
    #>

    [CmdletBinding()]
    # Suppress the unused parameter warning for the parameters that are not used in this function
    # They are used via BodyString & URIString functions
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "")]
    Param(
        # Component Type is one of the list
        [Parameter(
            Mandatory = $true
        )]
        [ValidateSet(
            'network-ips',
            'host-groups',
            'network-adapters',
            'network-services'
        )]
        [string]
        $ComponentType,
        $offset,
        $limit = 1000
    )

    begin {
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

    process {
        # changing "Content-Type" header specifically for this query, otherwise 415 : unsupported media type
        $script:SEPCloudConnection.header['Content-Type'] = 'application/json'

        $uri = New-URIString -endpoint ($resources.URI) -id $ComponentType
        $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
        $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)

        Write-Verbose -Message "Body is $(ConvertTo-Json -InputObject $body)"
        $result = Submit-Request -uri $uri -header $script:SEPCloudConnection.header -method $($resources.Method) -body $body

        # Test if pagination required
        if (($result.total -gt $result.data.count) -or ($result.total_count -gt $result.data.count)) {
            Write-Verbose -Message "Result limits hit. Retrieving remaining data based on pagination"
            do {
                # Update offset query param for pagination
                $offset = $result.data.count
                $uri = New-URIString -endpoint ($resources.URI) -id $id
                $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
                $nextResult = Submit-Request  -uri $uri  -header $script:SEPCloudConnection.header  -method $($resources.Method) -body $body
                $result.data += $nextResult.data
            } until (($result.data.count -ge $result.total) -or ($result.data.count -ge $result.total_count))
        }

        # apply correct PSType based on the 4 possible results options
        # Define a hashtable to map properties to their corresponding PSTypeName
        $typeMapping = @{
            identification  = "SEPCloud.adapter"
            classifications = "SEPCloud.ips_metadata"
            services        = "SEPCloud.network-services"
            hosts           = "SEPCloud.host-group"
        }

        # Function to check if a property has meaningful data
        # For some reason, when using if statement count gt 0 still shows true with no data, maybe empty strings
        function Test-MeaningfulData {
            param ([object]$data)
            return $null -ne $data -and ($data.Count -gt 0 -or -not [string]::IsNullOrEmpty($data))
        }

        # Iterate over the mapping to determine the correct PSTypeName
        foreach ($property in $typeMapping.Keys) {
            if (Test-MeaningfulData -data $result.data.$property) {
                $resources.ObjectTName = $typeMapping[$property]
                break
            }
        }

        # Apply correct format only after knowing which PSType to apply above
        $result = Test-ReturnFormat -result $result -location $resources.Result
        $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result

        # Removing "Content-Type: application/json" header
        $script:SEPCloudConnection.header.remove('Content-Type')

        return $result
    }
}
