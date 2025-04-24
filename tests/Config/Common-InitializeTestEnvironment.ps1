function Initialize-TestEnvironment {
    param ()

    [string] $script:Credential = $null
    [PSCustomObject] $script:configuration = $null

    # The session-cached copy of the module's configuration properties
    [PSCustomObject] $script:SEPCloudConnection = [PSCustomObject]@{
        BaseURL     = "api.sep.eu.securitycloud.symantec.com"
        Credential  = $null
        AccessToken = $null
        time        = (Get-Date)
        header      = $null
        pester      = "pester-env"
    }

    # Module name
    [string] $script:ModuleName = "PSSymantecCloud"

    # Load the configuration file
    $script:configuration = [PSCustomObject]@{
        BaseURL           = "api.sep.securitycloud.symantec.com"
        SEPCloudCredsPath = Join-Path -Path 'TestDrive:' -ChildPath 'creds.xml'
        CachedTokenPath   = Join-Path -Path 'TestDrive:' -ChildPath 'accessToken.xml'
    }

    # Set credentials & token files for test environment
    $username = "pester-user"
    $password = "pester-password"
    $token = "pester-token"
    $token_type = "pester-bearer"
    $tokenInfo = [PSCustomObject]@{
        Token        = $token
        Token_Type   = $token_type
        Token_Bearer = $token + " " + $token_type
        Expiration   = (Get-Date).AddSeconds(3600)
    }

    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($username, $securePassword)
    $credential | Export-Clixml -Path ($script:configuration).SEPCloudCredsPath
    $tokenInfo | Export-Clixml -Path ($script:configuration).CachedTokenPath
}

Initialize-TestEnvironment
