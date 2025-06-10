function Set-SEPCloudPolicy
{

    <#
    .SYNOPSIS
        Apply a SEP Cloud policy to a device group
    .DESCRIPTION
        Apply a SEP Cloud policy to a device group. Must include a specific location (also called policy target rule)
    .LINK
        https://github.com/Douda/PSSymantecCloud
    .PARAMETER policyName
        Name of the policy to apply
    .PARAMETER policyId
        Id of the policy to apply
        If not provided, Id will be pulled from the policy name
    .PARAMETER policyVersion
        Version of the policy to apply.
        If not provided, the latest version will be used by default
    .PARAMETER target_rules
        Alias: location
        Location (policy target rule) to apply the policy to.
        If not provided, the default location will be used
    .PARAMETER device_group_ids
        Device group ID to apply the policy to
    .EXAMPLE
        Set-SEPCloudPolicy -policyName "My Policy" -location "Default" -deviceGroupID "123456"
        Apply the latest version of the SEP Cloud policy named "My Policy" to the device group with ID "123456" at the location "Default"
    .EXAMPLE
        Set-SEPCloudPolicy -policyName "My Policy" -location "Default" -deviceGroupID "123456" -version 2
        Apply the version 2 of the SEP Cloud policy named "My Policy" to the device group with ID 123456 at the location Default
    #>

    [CmdletBinding(DefaultParameterSetName = "byName")]
    Param(
        [Parameter(ParameterSetName = "byName")]
        $policyName,

        [Alias("policy_uid")]
        $policyId,

        [Parameter(ParameterSetName = "byId")]
        [Alias("version")]
        $policyVersion,

        [Alias("location")]
        [Alias("targetRule")]
        [string[]]
        $target_rules = "Default",

        [Alias("deviceGroupId")]
        [string[]]
        $device_group_ids,

        $override = $true
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

        $uri = New-URIString -endpoint ($resources.URI) -id @($policyId, $policyVersion)
        $uri = Test-QueryParam -querykeys ($resources.Query.Keys) -parameters ((Get-Command $function).Parameters.Values) -uri $uri
        $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
        $result = Submit-Request -uri $uri -header $script:SEPCloudConnection.header -method $($resources.Method) -body $body
        $result = Test-ReturnFormat -result $result -location $resources.Result
        $result = Set-ObjectTypeName -TypeName $resources.ObjectTName -result $result
        return $result
    }
}
