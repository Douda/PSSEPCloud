function Test-QueryParam($querykeys, $parameters, $uri)
{
    <#
    .SYNOPSIS
    Builds a URI with query parameters for an endpoint

    .DESCRIPTION
    The Test-QueryParam function is used to build and test a custom query string for supported endpoints.

    .PARAMETER querykeys
    The endpoints query keys as defined in Get-SEPCloudAPIData

    .PARAMETER parameters
    The set of parameters passed within the cmdlets invocation

    .PARAMETER uri
    The endpoints URI
    #>

    Write-Verbose -Message "Build the query parameters for $(if ($querykeys){$querykeys -join ','}else{'<null>'})"
    $querystring = @()
    # Walk through all of the available query options presented by the endpoint
    # Note: Keys are used to search in case the value changes in the future across different API versions
    foreach ($query in $querykeys)
    {
        # Walk through all of the parameters defined in the function
        # Both the parameter name and parameter alias are used to match against a query option
        # It is suggested to make the parameter name "human friendly" and set an alias corresponding to the query option name
        foreach ($param in $parameters)
        {
            # If the parameter name matches the query option name, build a query string
            if (($param.Name -eq $query.Keys) -or ($param.Name -eq $query))
            {
                if ((Get-Variable -Name $param.Name).Value)
                {
                    Write-Verbose ('Building Query with "{0}: {1}"' -f $resources.Query[$param.Name], (Get-Variable -Name $param.Name).Value)
                }
                $querystring += Test-QueryObject -object (Get-Variable -Name $param.Name).Value -location $resources.Query[$param.Name] -params $querystring
            }
            # If the parameter alias matches the query option name, build a query string
            elseif (($param.Aliases -eq $query.Keys) -or ($param.Aliases -eq $query))
            {
                if ((Get-Variable -Name $param.Name).Value)
                {
                    Write-Verbose ('Building Query with "{0}: {1}"' -f (-join $resources.Query[$param.Aliases]), (Get-Variable -Name $param.Name).Value)
                }
                $querystring += Test-QueryObject -object (Get-Variable -Name $param.Name).Value -location $resources.Query[$param.Aliases] -params $querystring
            }
        }
    }

    # After all query options are exhausted, build a new URI with all defined query options
    $uri = New-QueryString -query $querystring -uri $uri
    Write-Verbose -Message "URI = $uri"

    return $uri
}
