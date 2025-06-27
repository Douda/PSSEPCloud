function New-BodyString
{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        $bodykeys,
        $parameters
    )
    <#
    .SYNOPSIS
    Function to create the body payload for an API request

    .DESCRIPTION
    This function compares the defined body parameters within Get-SEPCloudAPIData with any parameters set within the invocation process.
    If matches are found, a properly formatted and valid body payload is created and returned.

    .PARAMETER bodykeys
    All of the body options available to the endpoint

    .PARAMETER parameters
    All of the parameter options available within the parent function
  #>

    # Check if we should proceed with building the body string
    if (-not $PSCmdlet.ShouldProcess("API Request Body", "Build body string from parameters")) {
        return $null
    }

    # If sending a GET request, no body is needed
    if ($resources.Method -eq 'Get')
    {
        return $null
    }

    # Look at the list of parameters that were set by the invocation process
    # This is how we know which params were actually set by the call, versus defaulting to some zero, null, or false value

    # Now that custom params are added, let's inventory all invoked params

    Write-Verbose -Message 'Build the body parameters'
    $bodystring = @{ }
    # Walk through all of the available body options presented by the endpoint
    # Note: Keys are used to search in case the value changes in the future across different API versions
    foreach ($body in $bodykeys)
    {
        Write-Verbose "Adding $body..."

        # Array Object
        if ($resources.Body.$body.GetType().BaseType.Name -eq 'Array')
        {
            $bodyarray = $resources.Body.$body.Keys
            $arraystring = @{ }
            foreach ($arrayitem in $bodyarray)
            {
                # Walk through all of the parameters defined in the function
                # Both the parameter name and parameter alias are used to match against a body option
                # It is suggested to make the parameter name "human friendly" and set an alias corresponding to the body option name
                foreach ($param in $parameters)
                {
                    # If the parameter name or alias matches the body option name, build a body string

                    if ($param.Name -eq $arrayitem -or $param.Aliases -eq $arrayitem)
                    {
                        # Switch variable types
                        if ((Get-Variable -Name $param.Name).Value.GetType().Name -eq 'SwitchParameter')
                        {
                            $arraystring.Add($arrayitem, (Get-Variable -Name $param.Name).Value.IsPresent)
                        }
                        # All other variable types
                        elseif ($null -ne (Get-Variable -Name $param.Name).Value)
                        {
                            $arraystring.Add($arrayitem, (Get-Variable -Name $param.Name).Value)
                        }
                    }
                }
            }
            $bodystring.Add($body, @($arraystring))
        }

        # Non-Array Object
        else
        {
            # Walk through all of the parameters defined in the function
            # Both the parameter name and parameter alias are used to match against a body option
            # It is suggested to make the parameter name "human friendly" and set an alias corresponding to the body option name
            foreach ($param in $parameters)
            {
                # If the parameter name or alias matches the body option name, build a body string
                if (($param.Name -eq $body -or $param.Aliases -eq $body))
                {
                    if ((Get-Variable -Name $param.Name).Value)
                    {
                        # Switch variable types
                        if ((Get-Variable -Name $param.Name).Value.GetType().Name -eq 'SwitchParameter')
                        {
                            $bodystring.Add($body, (Get-Variable -Name $param.Name).Value.IsPresent)
                        }
                        # All other variable types
                        elseif ($null -ne (Get-Variable -Name $param.Name).Value -and (Get-Variable -Name $param.Name).Value.Length -gt 0)
                        {
                            $bodystring.Add($body, (Get-Variable -Name $param.Name).Value)
                        }
                    }
                }
            }
        }
    }

    # Store the results into a JSON string
    if (0 -ne $bodystring.count)
    {
        # $bodystring = ConvertTo-Json -InputObject $bodystring
        Write-Verbose -Message "Body = $(ConvertTo-Json -InputObject $bodystring)"
    }
    else
    {
        Write-Verbose -Message 'No body for this request'
    }
    return $bodystring
}
