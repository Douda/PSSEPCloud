function Set-SEPCloudRegion {
    <#
    .SYNOPSIS
    Sets the correct region for the SEPCloud API.

    .DESCRIPTION
    Sets the correct region for the SEPCloud API.
    The region parameter is the region that will be set for the SEPCloud API.

    .EXAMPLE
    Set-SEPCloudRegion -region 'North America'

    .PARAMETER region
    The region parameter is the region that will be set for the SEPCloud API.

    #>
    [cmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("North America", "Europe", "India")]
        $region
    )

    process {
        switch ($region) {
            'North America' {
                $script:SEPCloudConnection.BaseURL = "api.sep.us.securitycloud.symantec.com"
            }
            'Europe' {
                $script:SEPCloudConnection.BaseURL = "api.sep.eu.securitycloud.symantec.com"
            }
            'India' {
                $script:SEPCloudConnection.BaseURL = "api.sep.in.securitycloud.symantec.com"
            }
        }
    }
}
