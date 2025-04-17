function New-URIQuery($queryKeys, $parameters, $uri)
{

    <#
    .SYNOPSIS
        Builds a URI with query parameters for an uri
    .DESCRIPTION
        Builds a URI with query parameters for an uri.
        This function takes a list of keys and values, and constructs an URI with the query parameters.
    .PARAMETER queryKeys
        The query keys as defined in Get-SEPCloudAPIData
    .PARAMETER parameters
        The set of parameters passed as query values
    .PARAMETER uri
        The base URI to build from

    #>



    # Construct the uri
    $builder = New-Object System.UriBuilder($uri)
    $query = [System.Web.HttpUtility]::ParseQueryString($builder.Query)

    Write-Verbose -Message "Build the query parameters for $(if ($queryKeys){$queryKeys -join ','}else{'<null>'})"
    # Walk through all of the available query options
    foreach ($queryKey in $queryKeys)
    {
        # Walk through all of the parameters defined in the function
        # Both the parameter name and parameter alias are used to match against a query option
        # This will allow for easier readability of the code
        foreach ($param in $parameters)
        {
            # If the parameter name matches the query option name, build a query string
            if ($param.ContainsKey($queryKey))
            {
                if ($null -ne $param.Values)
                {
                    $query.Add($queryKey, $param[$queryKey])
                }
            }
        }
    }

    $builder.Query = $query.ToString()
    $uri = $builder.Uri.AbsoluteUri
    Write-Verbose -Message "URI = $uri"
    return $uri
}
