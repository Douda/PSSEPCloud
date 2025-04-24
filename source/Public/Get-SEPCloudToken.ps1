function Get-SEPCloudToken {
    <#
    .SYNOPSIS
    Generates an authenticated Token from the SEP Cloud API
    .DESCRIPTION
    Gathers Bearer Token from the SEP Cloud console to interact with the authenticated API
    Securely stores credentials or valid token locally (By default on TEMP location)
    Connection information available here : https://sep.securitycloud.symantec.com/v2/integration/client-applications

    .PARAMETER clientId
    clientId parameter required to generate a token

    .PARAMETER secret
    secret parameter required in combinaison to clientId to generate a token

    .PARAMETER cacheOnly
    if set to $true, will only lookup for in-memory or local cache of token/credentials.
    Will not prompt for credentials or generate a new token.
    Usefful for automation.

    .INPUTS
    [string] clientId
    [string] secret
    .OUTPUTS
    [PSCustomObject] Token

    .EXAMPLE
    Get-SEPCloudToken
    .EXAMPLE
    Get-SEPCloudToken(clientId,secret)
    .EXAMPLE
    Get-SEPCloudToken -clientId "myclientid" -secret "mysecret"

    .NOTES
    Function logic
    - Test if token is already loaded in memory (and verify its validity)
    - Test locally stored encrypted token (and verify its validity)
    - Test if credentials is already loaded in memory to generate a token
    - Test locally stored encrypted Client/secret to generate a token
    - Requests Client/secret to generate token
    #>


    [CmdletBinding(DefaultParameterSetName = 'ClientIdSecret')]
    param (
        # clientId from SEP Cloud Connection App
        [Parameter(
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ClientIdSecret'
        )]
        [string]
        $clientId,

        # secret from SEP Cloud Connection App
        [Parameter(
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'ClientIdSecret'
        )]
        [string]
        $secret,

        # Unattended
        [switch]
        [Alias("unattended")]
        $cacheOnly
    )

    # If -cacheOnly do not attempt to prompt for credentials for unattended mode
    if ($cacheOnly) {
        return $null
    }

    # Test if clientId and secret are provided to generate a token without testing for locally stored encrypted token/credentials
    if ($clientId -and $secret) {
        Write-Verbose -Message "clientId & secret provided - testing to generate a token"
        $encodedCreds = [convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($clientId + ':' + $secret)))

        try {
            $params = @{
                Uri             = 'https://' + $script:SEPCloudConnection.baseURL + '/v1/oauth2/tokens'
                Method          = 'POST'
                Headers         = @{
                    Host          = $script:SEPCloudConnection.baseURL
                    Accept        = "application/json"
                    Authorization = "Basic " + $encodedCreds
                }
                useBasicParsing = $true
            }
            $Response = Invoke-RestMethod @params

            if ($null -ne $response) {
                # Cache the credentials
                Write-Verbose -Message "credentials valid - caching credentials : $($script:configuration.SEPCloudCredsPath)"
                $credentialsDirectory = Split-Path -Path $script:configuration.SEPCloudCredsPath -Parent
                if (-not (Test-Path -Path $credentialsDirectory)) {
                    New-Item -ItemType Directory -Path $credentialsDirectory | Out-Null
                }
                $encodedCreds | Export-Clixml -Path $script:configuration.SEPCloudCredsPath
                $script:SEPCloudConnection.Credential = $encodedCreds

                # Cache the token
                Write-Verbose "credentials valid - returning valid Bearer token"
                $cachedToken = [PSCustomObject]@{
                    Token        = $response.access_token
                    Token_Type   = $response.token_type
                    Token_Bearer = $response.token_type.ToString() + " " + $response.access_token
                    Expiration   = (Get-Date).AddSeconds($response.expires_in) # token expiration is 3600s
                }
                $script:SEPCloudConnection.AccessToken = $cachedToken
                $tokenDirectory = Split-Path -Path $script:configuration.cachedTokenPath -Parent
                if (-not (Test-Path -Path $tokenDirectory)) {
                    New-Item -ItemType Directory -Path $tokenDirectory | Out-Null
                }
                $cachedToken | Export-Clixml -Path $script:configuration.cachedTokenPath

                Write-Verbose -Message "stored valid token : $($script:configuration.cachedTokenPath)"
                return $cachedToken
            }
        } catch {
            $message = "Authentication error - Failed to gather token from locally stored credentials"
            $message = $message + "`n" + "Expected HTTP 200, got $($_.Exception.Response.StatusCode)" + "`n"
            $message = $message + "delete cached credentials"
            $message = $message + "`n" + "Error : $($_.Exception.Response.StatusCode) : $($_.Exception.Response.StatusDescription)"
            Write-Verbose -Message $message
        }
    }

    # Test if token already in memory
    if ($null -ne $script:SEPCloudConnection.AccessToken.access_token) {
        # Check if still valid
        if (Test-SEPCloudToken) {
            Write-Verbose -Message "Token in-memory is still valid"
            return $script:SEPCloudConnection.AccessToken
        } else {
            try { Remove-Item -Path $script:configuration.cachedTokenPath -ErrorAction SilentlyContinue } catch {}
            $script:SEPCloudConnection.AccessToken = $null
        }
    }

    # Test if token present on the disk
    if (Test-Path -Path $script:configuration.cachedTokenPath) {
        $cachedToken = Import-Clixml -Path $script:configuration.cachedTokenPath
        # Check if still valid
        if (Test-SEPCloudToken -token $cachedToken) {
            Write-Verbose "Token from disk is still valid"
            return $cachedToken
        } else {
            Write-Verbose -Message "Token from disk expired - deleting"
            try { Remove-Item -Path $script:configuration.cachedTokenPath -ErrorAction SilentlyContinue } catch {}
            $script:SEPCloudConnection.AccessToken = $null
        }
    }

    # Test if OAuth cred present in memory
    if ($script:SEPCloudConnection.Credential) {
        Write-Verbose -Message "credentials in-memory available - testing"
        try {
            $params = @{
                Uri     = 'https://' + $script:SEPCloudConnection.baseURL + '/v1/oauth2/tokens'
                Method  = 'POST'
                Headers = @{
                    Host          = $script:SEPCloudConnection.baseURL
                    Accept        = "application/json"
                    Authorization = "Basic " + $script:SEPCloudConnection.Credential
                }
            }
            $response = Invoke-RestMethod @params

            if ($null -ne $response) {
                # Get the auth token from the response. Store it locally & in memory
                Write-Verbose -Message "credentials in-memory valid - returning valid token"
                $cachedToken = [PSCustomObject]@{
                    Token        = $response.access_token
                    Token_Type   = $response.token_type
                    Token_Bearer = $response.token_type + " " + $response.access_token
                    Expiration   = (Get-Date).AddSeconds($response.expires_in) # token expiration is 3600s
                }
                $cachedToken | Export-Clixml -Path $script:configuration.cachedTokenPath
                $script:SEPCloudConnection.AccessToken = $cachedToken
                Write-Verbose -Message "stored valid token : $($script:configuration.cachedTokenPath)"
                return $cachedToken
            }
        } catch {
            $message = "Authentication error - Failed to gather token from locally stored credentials"
            $message = $message + "`n" + "Expected HTTP 200, got $($_.Exception.Response.StatusCode)" + "`n"
            $message = $message + "delete cached credentials"
            $message = $message + "`n" + "Error : $($_.Exception.Response.StatusCode) : $($_.Exception.Response.StatusDescription)"
            Write-Verbose -Message $message
            $script:SEPCloudConnection.Credential = $null
        }
    }

    # Test if OAuth cred present on the disk
    if ((Test-Path -Path $script:configuration.SEPCloudCredsPath)) {
        Write-Verbose "credentials on disk available - testing"
        try {
            $params = @{
                Uri     = 'https://' + $script:SEPCloudConnection.baseURL + '/v1/oauth2/tokens'
                Method  = 'POST'
                Headers = @{
                    Host          = $script:SEPCloudConnection.baseURL
                    Accept        = "application/json"
                    Authorization = "Basic " + (Import-Clixml -Path $script:configuration.SEPCloudCredsPath)
                }
            }
            $response = Invoke-RestMethod @params

            if ($null -ne $response) {
                # Get the auth token from the response. Store it locally & in memory
                Write-Verbose "credentials valid - returning valid token"
                $cachedToken = [PSCustomObject]@{
                    Token        = $response.access_token
                    Token_Type   = $response.token_type
                    Token_Bearer = $response.token_type + " " + $response.access_token
                    Expiration   = (Get-Date).AddSeconds($response.expires_in) # token expiration is 3600s
                }
                $cachedToken | Export-Clixml -Path $script:configuration.cachedTokenPath
                Write-Verbose -Message "stored valid token : $($script:configuration.cachedTokenPath)"
                $script:SEPCloudConnection.AccessToken = $cachedToken
                return $cachedToken
            }

        } catch {
            $message = "Authentication error - Failed to gather token from locally stored credentials"
            $message = $message + "`n" + "Expected HTTP 200, got $($_.Exception.Response.StatusCode)" + "`n"
            $message = $message + "delete cached credentials"
            $message = $message + "`n" + "Error : $($_.Exception.Response.StatusCode) : $($_.Exception.Response.StatusDescription)"
            Write-Verbose -Message $message
        }
    }

    # If no token nor OAuth creds available locally
    # Encode clientId and secret to create Basic Auth string
    # Authentication requires the following "Basic + encoded CliendID:Clientsecret"

    Write-Verbose -Message "testing authentication with client/secret provided"
    if ($clientID -eq "" -or $secret -eq "") {

        Write-Output "No local credentials found. Please provide clientId and secret to generate a token"
        $clientId = Read-Host -Prompt "Enter clientId"
        $secret = Read-Host -Prompt "Enter secret" # -MaskInput TODO removed maskedInput. Not working with PS 5.1
    }
    $encodedCreds = [convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($clientId + ':' + $secret)))

    try {
        $params = @{
            Uri             = 'https://' + $script:SEPCloudConnection.baseURL + '/v1/oauth2/tokens'
            Method          = 'POST'
            Headers         = @{
                Host          = $script:SEPCloudConnection.baseURL
                Accept        = "application/json"
                Authorization = "Basic " + $encodedCreds
            }
            useBasicParsing = $true
        }
        $Response = Invoke-RestMethod @params

        if ($null -ne $response) {
            # Cache the credentials
            Write-Verbose -Message "credentials valid. caching credentials : $($script:configuration.SEPCloudCredsPath)"
            $credentialsDirectory = Split-Path -Path $script:configuration.SEPCloudCredsPath -Parent
            if (-not (Test-Path -Path $credentialsDirectory)) {
                New-Item -ItemType Directory -Path $credentialsDirectory | Out-Null
            }
            $encodedCreds | Export-Clixml -Path $script:configuration.SEPCloudCredsPath
            $script:SEPCloudConnection.Credential = $encodedCreds

            # Cache the token
            Write-Verbose "credentials valid - returning valid Bearer token"
            $cachedToken = [PSCustomObject]@{
                Token        = $response.access_token
                Token_Type   = $response.token_type
                Token_Bearer = $response.token_type.ToString() + " " + $response.access_token
                Expiration   = (Get-Date).AddSeconds($response.expires_in) # token expiration is 3600s
            }
            $script:SEPCloudConnection.AccessToken = $cachedToken
            $tokenDirectory = Split-Path -Path $script:configuration.cachedTokenPath -Parent
            if (-not (Test-Path -Path $tokenDirectory)) {
                New-Item -ItemType Directory -Path $tokenDirectory | Out-Null
            }
            $cachedToken | Export-Clixml -Path $script:configuration.cachedTokenPath

            Write-Verbose -Message "stored valid token : $($script:configuration.cachedTokenPath)"
            return $cachedToken
        }
    } catch {
        $message = "Authentication error - Failed to gather token from locally stored credentials"
        $message = $message + "`n" + "Expected HTTP 200, got $($_.Exception.Response.StatusCode)" + "`n"
        $message = $message + "delete cached credentials"
        $message = $message + "`n" + "Error : $($_.Exception.Response.StatusCode) : $($_.Exception.Response.StatusDescription)"
        Write-Verbose -Message $message
    }
}
