function Remove-SEPCloudToken
{
    <# TODO write help
      .SYNOPSIS
      This is a sample Private function only visible within the module.

      .DESCRIPTION
      This sample function is not exported to the module and only return the data passed as parameter.

      .EXAMPLE
      $null = Remove-SEPCloudToken -PrivateData 'NOTHING TO SEE HERE'

      .PARAMETER PrivateData
      The PrivateData parameter is what will be returned without transformation.

      #>
    [cmdletBinding()]
    [OutputType([string])]
    param()

    process
    {
        $script:SEPCloudConnection | Add-Member -MemberType NoteProperty -Name AccessToken -Value $null -Force -ErrorAction SilentlyContinue
        $script:configuration | Add-Member -MemberType NoteProperty -Name AccessToken  -Value $null -Force -ErrorAction SilentlyContinue
        if ($script:configuration.CachedTokenPath)
        {
            try
            {
                Remove-Item $script:configuration.CachedTokenPath -Force
            }
            catch {
                Write-Error "$_"
            }
        }
    }

}
