function Remove-SEPCloudPolicy
{

    <#
    .SYNOPSIS
        Removes a SEP Cloud policy from a device group
    .DESCRIPTION
        Removes a SEP Cloud policy from a device group.
        Must include a specific location (also called policy target rule)
    .LINK
        https://github.com/Douda/PSSymantecCloud
    .PARAMETER policyName
        Name of the policy to apply
    .PARAMETER policyVersion
        Version of the policy to apply.
        If not provided, the latest version will be used
    .PARAMETER targetRules
        Alias: location
        Location (policy target rule) to apply the policy to
        If not provided, the default location will be used
    .PARAMETER deviceGroupId
        Device group ID to apply the policy to
    .OUTPUTS
        None
    .EXAMPLE
        Remove-SEPCloudPolicy -policyName "My Policy" -location "Default" -deviceGroupId "123456"
        Removes the latest version of the SEP Cloud policy named "My Policy" to the device group with ID "123456" at the location "Default"
    #>

    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        $policyName,

        [Alias("version")]
        $policyVersion,

        [Alias("policy_uid")]
        $policyId,

        [Parameter(Mandatory = $true)]
        [Alias("target_rules")]
        [Alias("location")]
        [string[]]
        $targetRule = "Default",

        [Parameter(Mandatory = $true)]
        [Alias("device_group_ids")]
        [string[]]
        $deviceGroupId
    )

    begin
    {
        # Check to ensure that a session to the SaaS exists and load the needed header data for authentication
        Test-SEPCloudConnection | Out-Null

        # API data references the name of the function
        # For convenience, that name is saved here to $function
        $function = $MyInvocation.MyCommand.Name

        # Retrieve all of the URI, method, body, query, result, and success details for the API endpoint
        Write-Verbose -Message "Gather API Data for $function"
        $resources = Get-SEPCloudAPIData -endpoint $function
        Write-Verbose -Message "Load API data for $($resources.Function)"
        Write-Verbose -Message "Description: $($resources.Description)"
    }

    process
    {
        # changing "Content-Type" header specifically for this query, otherwise 415 : unsupported media type
        # $script:SEPCloudConnection.header += @{ 'Accept' = 'application/json' }

        if ($policyName -and ($null -eq $policyId))
        {
            Write-Verbose -Message "Searching ID for $policyName"
            $policyId = (Get-SEPCloudPolicesSummary | Where-Object { $_.name -eq "$policyName" }).policy_uid
        }
        if ($null -eq $policyVersion )
        {
            Write-Verbose -Message "No policy version provided, retrieving the latest version of $policyName"
            # By default the API returns the latest version of a policy
            $policyVersion = (Get-SEPCloudPolicesSummary | Where-Object { $_.name -eq "$policyName" }).policy_version
        }
        $id = @($policyId, $policyVersion)
        $uri = New-URIString -endpoint ($resources.URI) -id $id
        $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
        $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
        if ($PSCmdlet.ShouldProcess("Policy: $policyName (ID: $policyId)", "Remove SEP Cloud Policy")) {
            $result = Submit-Request -uri $uri -header $script:SEPCloudConnection.header -method $($resources.Method) -body $body
        } else {
            return
        }
        $result = Test-ReturnFormat -result $result -location $resources.Result
        $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result

        # Removing "Content-Type: application/json" header
        # $script:SEPCloudConnection.header.remove('Content-Type')

        return $result
    }
}
