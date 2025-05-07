function Get-PolicyInfo {
    <#
    .SYNOPSIS
    Retrieve policy information including policy_uid and version.

    .DESCRIPTION
    This function retrieves the policy_uid from the policy name if not provided and gets the latest policy version if no version is provided.

    .PARAMETER policy_name
    The name of the policy.

    .PARAMETER policy_uid
    The unique identifier of the policy.

    .PARAMETER version
    The version of the policy.

    .OUTPUTS
    Returns a hashtable with policy_uid and version.
    #>
    param (
        [string]$policy_name,
        [string]$policy_uid,
        [string]$version
    )

    # Gets policy_uid from policy name if not provided
    if ($policy_name -and ($null -eq $policy_uid -or $policy_uid -eq "")) {
        $policy_info = Get-SEPCloudPolicesSummary | Where-Object { $_.name -eq $policy_name }

        # Check if $policy_info is empty
        if ($null -eq $policy_info -or $policy_info.Count -eq 0) {
            throw "Policy with name '$policy_name' not found."
        }

        $policy_uid = $policy_info.policy_uid
        Write-Verbose -Message "policy_name : $policy_name"
        Write-Verbose -Message "policy_uid : $policy_uid"
    }

    # Gets the latest policy version if no version is provided
    if ($null -eq $version -or $version -eq "") {
        $version = Get-SEPCloudPolicesSummary | Where-Object { $_.policy_uid -eq $policy_uid } | Select-Object -ExpandProperty policy_version
        Write-Verbose -Message "No version provided, using latest policy version : $version"
    }

    return @{
        policy_name = $policy_name
        policy_uid   = $policy_uid
        version      = $version
    }
}
