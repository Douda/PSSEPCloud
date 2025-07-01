function Connect-SEPCloud {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        # Additional information to be added, takes hashtable as input
        [hashtable] $UserAgent,
        [switch] $cacheOnly,
        $clientId,
        $secret
    )

    process {
        # Create User Agent string
        $UserAgentString = New-UserAgentString -UserAgentHash $UserAgent
        $PSBoundParameters.Remove($UserAgent) | Out-Null
        Remove-Variable -Force -Name UserAgent -ErrorAction SilentlyContinue

        Write-Verbose -Message "Using User Agent $($UserAgentString)"

        # If called from Initialize-SEPCloudConfiguration
        # get token from cache only to avoid prompting for creds while loading the module
        if ($cacheOnly) {
            Write-Verbose -Message "Token request using cachedOnly"
            $token = Get-SEPCloudToken -cacheOnly
        } elseif ($clientId -and $secret) {
            Write-Verbose -Message "Token request using client and secret"
            $token = Get-SEPCloudToken -client $clientId -Secret $secret
        } else {
            $token = Get-SEPCloudToken
        }

        # if we have a token, add it to the header
        if ($null -ne $token) {
            $head = @{
                'Authorization' = "$($Token.Token_Bearer)";
                'User-Agent'    = $UserAgentString#;
                # 'Host'          = $($script:SEPCloudConnection.BaseURL)
            }
            $script:SEPCloudConnection | Add-Member -Type NoteProperty -Name 'header' -Value $head -Force
        } else {
            # If no token, just add User-Agent
            $head = @{
                'User-Agent' = $UserAgentString#;
                # 'Host'          = $($script:SEPCloudConnection.BaseURL)
            }
            $script:SEPCloudConnection | Add-Member -Type NoteProperty -Name 'header' -Value $head -Force
        }
    }
}
