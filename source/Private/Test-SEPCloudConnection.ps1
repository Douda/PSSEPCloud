function Test-SEPCloudConnection
{

    Write-Verbose -Message "Test-SEPCloudConnection: $script:SEPCloudConnection.AccessToken.Token"

    Write-Verbose -Message "Validate the SEP Cloud token"
    if (Test-SEPCloudToken)
    {
        Write-Verbose -Message "token valid - returning"
        return $True
    }
    else
    {
        Write-Verbose -Message "token expired or invalid - requesting a new one"
        Get-SEPCloudToken
        Write-Verbose -Message ("New token will expire at" + $((Get-Date) -lt $script:SEPCloudConnection.AccessToken.Expiration))
    }
}
