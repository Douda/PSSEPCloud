function New-URIString
{

    <#
    .SYNOPSIS
        Builds a valid URI
    .DESCRIPTION
        Builds a valid URI based off of the constructs defined in the Get-SEPCloudAPIData resources for the cmdlet.
        Inserts any object IDs into the URI if {id} is specified within the constructs.
    .PARAMETER baseURL
        The base URL for the API
    .PARAMETER id
        The ID of an object to be inserted into the URI
        Accepts an array of IDs from 0 to 2 strings
    .PARAMETER endpoint
        The endpoint to be inserted into the URI
        Optionally at the end of the base URL if no {id} is specified
    .EXAMPLE
        New-URIString -baseURL "192.168.3.11" -id 56789 -endpoint "/v1/device-groups"
        Returns "https://192.168.3.11/v1/device-groups/56789"
    .EXAMPLE
        New-URIString -baseURL "192.168.3.11" -id 56789 -endpoint "/v1/device-groups/{id}/devices"
        Returns "https://192.168.3.11/v1/device-groups/56789/devices"
    #>



    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $baseURL = $script:SEPCloudConnection.BaseURL,

        [Parameter()]
        [ValidateCount(0, 2)]
        [array]
        $id,

        [Parameter(
            Mandatory = $true
        )]
        [string]
        $endpoint
    )

    Write-Verbose -Message 'Verify that we have a valid base URL'
    if ($null -eq $baseURL -or '' -eq $baseURL) {
        throw 'no API region set. Please set it with Set-SEPCloudRegion'
    }

    Write-Verbose -Message 'Build the URI'
    $uri = ('https://' + $baseUrl + $endpoint)

    # If we find {id} in the path, replace it with the $id value
    if ($endpoint -match '{id}')
    {
        # regex to replace the {id} with the next value in the array
        $idx = @(0)
        $uri = [regex]::Replace($uri, '{id}|$', {
                # if there is a "next value" in the list
                if ($next = $id[$idx[0]++])
                {
                    # if matching EOL
                    if (-not $args[0].Value)
                    {
                        return '/' + $next
                    }
                    else
                    {
                        $next
                    }
                }
            })
    }

    # Otherwise, only add the $id value at the end if it exists (for single object retrieval)
    else
    {
        # If $id has 2 elements can't append both ids to URI
        if ($id.Count -gt 1)
        {
            $message = "2 ids provided : '$id'"
            $message += "endpoint $endpoint allows only one id :"
            Write-Error -Message $message -ErrorAction Stop
        }
        if ($id.Count -eq 1)
        {
            $uri += "/$id"
        }
    }

    Write-Verbose -Message "URI = $uri"
    return $uri
}

# live test
# $BaseURL = "api.my.test.com"
# $endpoint = "/v1/{id}/device-groups"
# $id = @("123456", "789012")

# New-URIString -endpoint $endpoint -id $id -baseURL $BaseURL
