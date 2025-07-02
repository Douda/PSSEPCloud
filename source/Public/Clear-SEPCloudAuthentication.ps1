function Clear-SEPCloudAuthentication
{
    <#
    .SYNOPSIS
        Clears out any API token from memory, as well as from local file storage.
    .DESCRIPTION
        Clears out any API token from memory, as well as from local file storage.
    .EXAMPLE
        Clear-SepCloudAuthentication

        Clears out any API token from memory, as well as from local file storage.
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param ()

    if ($PSCmdlet.ShouldProcess("SEP Cloud Authentication", "Clear stored authentication tokens and credentials")) {
        # Remove the cached authentication data from memory
        # Using if statements to avoid errors when the variable does not exist or not initialized
        if ($script:configuration.CachedToken)
        {
            $script:configuration.CachedToken = $null
        }
        if ($script:Credential)
        {
            $script:Credential = $null
        }
        if ($script:SEPCloudConnection.AccessToken)
        {
            $script:SEPCloudConnection.AccessToken = $null
        }
        if ($script:SEPCloudConnection.Credential)
        {
            $script:SEPCloudConnection.Credential = $null
        }

        # remove the cached authentication data from disk
        Remove-Item -Path $($script:configuration.CachedTokenPath) -Force -ErrorAction SilentlyContinue -ErrorVariable ev
        Remove-Item -Path $($script:configuration.SEPCloudCredsPath) -Force -ErrorAction SilentlyContinue -ErrorVariable ev

        if (($null -ne $ev) -and
                ($ev.Count -gt 0) -and
                ($ev[0].FullyQualifiedErrorId -notlike 'PathNotFound*'))
        {
            $message = "Experienced a problem trying to remove the file that persists the Access Token " + $($script:configuration.SEPCloudCredsPath)
            $message += "Experienced a problem trying to remove the file that persists the Access Credentials " + $($script:configuration.CachedTokenPath)
            Write-Warning -Message $message
        }
        
        Write-Verbose "Authentication data cleared from memory and disk"
    }
}
