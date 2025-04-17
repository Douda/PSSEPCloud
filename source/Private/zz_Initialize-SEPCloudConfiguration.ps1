####################################
# Init script for the whole module #
####################################

## This is the initialization script for the module.  It is invoked at the end of the module's
## prefix file as "zz_" to load this module at last.  This is done to ensure that all other functions are first loaded
## This function should be private but will stay Public for the moment as it needs to be the last function to be loaded in the module
## TODO make this function private

# Update the data types when loading the module
Update-TypeData -PrependPath (Join-Path -Path $PSScriptRoot -ChildPath 'PSSymantecCloud.Types.ps1xml')

# The credentials used to authenticate to the SES Cloud API
[string] $script:Credential = $null # string type used as credentials is OAuth2 token

# The session-cached copy of the module's configuration properties
# Configuration contains user-defined properties
# SEPCloudConnection contains the connection information to the SES Cloud API
[PSCustomObject] $script:configuration = $null
[PSCustomObject] $script:SEPCloudConnection = [PSCustomObject]@{
    BaseURL     = "api.sep.eu.securitycloud.symantec.com"
    Credential  = $null
    AccessToken = $null
    time        = (Get-Date)
    header      = $null
}

# Module name
[string] $script:ModuleName = "PSSymantecCloud"

# Load the configuration file
$script:configuration = [PSCustomObject]@{
    BaseURL           = "api.sep.securitycloud.symantec.com"
    SEPCloudCredsPath = [System.IO.Path]::Combine(
        [System.Environment]::GetFolderPath('LocalApplicationData'),
        'PSSymantecCloud',
        'creds.xml')
    CachedTokenPath   = [System.IO.Path]::Combine(
        [System.Environment]::GetFolderPath('LocalApplicationData'),
        'PSSymantecCloud',
        'accessToken.xml')
}


function Initialize-SEPCloudConfiguration
{
    <#
    .SYNOPSIS
        Populates the configuration of the module for this session, loading in any values
        that may have been saved to disk.

    .DESCRIPTION
        Populates the configuration of the module for this session, loading in any values
        that may have been saved to disk.

    .NOTES
        Internal helper method.  This is actually invoked at the END of this file.
    #>
    [CmdletBinding()]
    param()

    # Load credential from disk if it exists
    if (Test-Path -Path $($script:configuration.SEPCloudCredsPath))
    {
        try
        {
            Write-Verbose -Message "Loading credential from $($script:configuration.SEPCloudCredsPath)"
            $script:Credential = Import-Clixml -Path $($script:configuration.SEPCloudCredsPath) -ErrorAction SilentlyContinue
            $script:SEPCloudConnection.Credential = Import-Clixml -Path $($script:configuration.SEPCloudCredsPath) -ErrorAction SilentlyContinue
        }
        catch
        {
            Write-Verbose "No credentials found from $($script:configuration.SEPCloudCredsPath)"
        }
    }

    # Load access token from disk
    if (Test-Path -Path $($script:configuration.CachedTokenPath))
    {
        try
        {
            Write-Verbose -Message "Loading access token from $($script:configuration.CachedTokenPath)"
            Add-Member -Type NoteProperty -Name AccessToken -Value (Import-Clixml -Path $($script:configuration.CachedTokenPath) -ErrorAction SilentlyContinue) -InputObject $SEPCloudConnection -Force
        }
        catch
        {
            Write-Verbose -Message "Failed to import access token from $($script:configuration.CachedTokenPath): $_" -Verbose
        }
    }

    # Test for existing access token and refresh token
    if (Test-SEPCloudToken)
    {
        # Load headers if access token exists
        $UserAgentString = New-UserAgentString
        $script:SEPCloudConnection.Header = @{
            'Authorization' = $script:SEPCloudConnection.AccessToken.Token_Bearer
            'User-Agent'    = $UserAgentString
        }
    }

    # Attempt to connect to the SaaS with cached token or credentials
    # Will only attempt to connect via cached method (token or credentials) and not prompt for credentials
    Connect-SEPCloud -cacheOnly
}

# Invoke the initialization method to populate the configuration
Initialize-SEPCloudConfiguration #-Verbose #TODO remove verbose when done testing
