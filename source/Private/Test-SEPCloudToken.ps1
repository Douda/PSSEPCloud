function Test-SEPCloudToken
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [PSCustomObject]
        $token
    )

    # Token passed as parameter
    if ($token)
    {
        if ((Get-Date) -lt $token.Expiration)
        {
            return $True
        }
    }

    # In memory token
    if ($script:SEPCloudConnection.AccessToken)
    {
        if ((Get-Date) -lt $script:SEPCloudConnection.AccessToken.Expiration)
        {
            return $True
        }
        else
        {
            Remove-SEPCloudToken
            return $false
        }
    }

    return $False
}
