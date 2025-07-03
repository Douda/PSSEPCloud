# PSSEPCloud Commands Reference

This document provides comprehensive documentation for all PowerShell commands available in the PSSEPCloud module. Each command includes its synopsis, description, parameters, examples, and additional information.

## Table of Contents

### 🔐 Authentication & Connection
- [Connect-SEPCloud](#connect-sepcloud)
- [Get-SEPCloudToken](#get-sepcloudtoken)
- [Set-SEPCloudRegion](#set-sepcloudregion)
- [Clear-SEPCloudAuthentication](#clear-sepcloudauthentication)

### 💻 Device Management
- [Get-SEPCloudDevice](#get-sepclouddevice)
- [Get-SEPCloudDeviceDetails](#get-sepclouddevicedetails)
- [Get-SEPCloudGroup](#get-sepcloudgroup)
- [Get-SEPCloudGroupPolicies](#get-sepcloudgrouppolicies)
- [Move-SEPCloudDevice](#move-sepclouddevice)
- [Start-SEPCloudFullScan](#start-sepcloudfullscan)
- [Start-SEPCloudQuickScan](#start-sepcloudquickscan)
- [Start-SEPCloudDefinitionUpdate](#start-sepclouddefinitionupdate)

### 📋 Policy Management
- [Get-SEPCloudPolicesSummary](#get-sepcloudpolicessummary)
- [Get-SEPCloudPolicyDetails](#get-sepcloudpolicydetails)
- [Set-SEPCloudPolicy](#set-sepcloudpolicy)
- [Remove-SEPCloudPolicy](#remove-sepcloudpolicy)
- [Update-AllowListPolicyByFileHash](#update-allowlistpolicybyfilehash)
- [Update-AllowListPolicyByFileName](#update-allowlistpolicybyfilename)

### 🛡️ Threat Intelligence
- [Get-SEPCloudThreatIntelCveProtection](#get-sepcloudthreatintelcveprotection)
- [Get-SEPCloudThreatIntelFileInsight](#get-sepcloudthreatintelfileinsight)
- [Get-SEPCloudThreatIntelFileProcessChain](#get-sepcloudthreatintelfileprocesschain)
- [Get-SEPCloudThreatIntelFileProtection](#get-sepcloudthreatintelfileprotection)
- [Get-SEPCloudThreatIntelFileRelated](#get-sepcloudthreatintelfilerelated)
- [Get-SEPCloudThreatIntelNetworkInsight](#get-sepcloudthreatintelnetworkinsight)
- [Get-SEPCloudThreatIntelNetworkProtection](#get-sepcloudthreatintelnetworkprotection)

### 📊 Incident & Event Management
- [Get-SEPCloudIncidents](#get-sepcloudincidents)
- [Get-SEPCloudIncidentDetails](#get-sepcloudincidentdetails)
- [Get-SEPCloudEvents](#get-sepcloudevents)

### 🗂️ File & Hash Management
- [Block-SEPCloudFile](#block-sepcloudfile)
- [Get-SEPCloudFileHashDetails](#get-sepcloudfilehashdetails)

### ⚙️ System Information
- [Get-SEPCloudComponentType](#get-sepcloudcomponenttype)
- [Get-SEPCloudEDRDumpsList](#get-sepcloudedrumpslist)
- [Get-SEPCloudTargetRules](#get-sepcloudtargetrules)
- [Get-SEPCloudFeatureList](#get-sepcloudfeaturelist)

---

## 🔐 Authentication & Connection

### Connect-SEPCloud

**Synopsis:** Establishes connection to SEP Cloud API

**Description:** Establishes an authenticated connection to the SEP Cloud API using client credentials or cached tokens.

**Parameters:**
- `UserAgent` [hashtable] - Additional information to be added as User Agent
- `cacheOnly` [switch] - Use cached credentials only, do not prompt for new credentials
- `clientId` [string] - Client ID for authentication
- `secret` [string] - Secret key for authentication

**Examples:**
```powershell
# Connect using interactive authentication
Connect-SEPCloud

# Connect with specific credentials
Connect-SEPCloud -clientId "your-client-id" -secret "your-secret"

# Connect using cached credentials only
Connect-SEPCloud -cacheOnly
```

---

### Get-SEPCloudToken

**Synopsis:** Generates an authenticated Token from the SEP Cloud API

**Description:** Gathers Bearer Token from the SEP Cloud console to interact with the authenticated API. Securely stores credentials or valid token locally. Connection information available at: https://sep.securitycloud.symantec.com/v2/integration/client-applications

**Parameters:**
- `clientId` [string] - Client ID parameter required to generate a token
- `secret` [string] - Secret parameter required in combination to clientId to generate a token
- `cacheOnly` [switch] (Alias: unattended) - If set to $true, will only lookup for in-memory or local cache of token/credentials

**Inputs:** [string] clientId, [string] secret

**Outputs:** [PSCustomObject] Token

**Examples:**
```powershell
# Interactive token request
Get-SEPCloudToken

# Generate token with specific credentials
Get-SEPCloudToken -clientId "myclientid" -secret "mysecret"

# Use cached token only
Get-SEPCloudToken -cacheOnly
```

**Notes:** Function logic follows this order:
1. Test if token is already loaded in memory (and verify its validity)
2. Test locally stored encrypted token (and verify its validity)
3. Test if credentials is already loaded in memory to generate a token
4. Test locally stored encrypted Client/secret to generate a token
5. Requests Client/secret to generate token

---

### Set-SEPCloudRegion

**Synopsis:** Sets the correct region for the SEPCloud API

**Description:** Sets the correct region for the SEPCloud API. The region parameter is the region that will be set for the SEPCloud API.

**Parameters:**
- `region` [string] (Mandatory) - The region that will be set for the SEPCloud API. Valid values: "North America", "Europe", "India"

**Examples:**
```powershell
# Set region to North America
Set-SEPCloudRegion -region 'North America'

# Set region to Europe
Set-SEPCloudRegion -region 'Europe'

# Set region to India
Set-SEPCloudRegion -region 'India'
```

---

### Clear-SEPCloudAuthentication

**Synopsis:** Clears out any API token from memory, as well as from local file storage

**Description:** Clears out any API token from memory, as well as from local file storage.

**Parameters:** None

**Examples:**
```powershell
# Clear all authentication data
Clear-SEPCloudAuthentication
```

---

## 💻 Device Management

### Get-SEPCloudDevice

**Synopsis:** Gathers list of devices from the SEP Cloud console

**Description:** Gathers list of devices from the SEP Cloud console with automatic pagination support and various filtering options.

**Parameters:**
- `client_version` [string] (Alias: ClientVersion) - Version of agent installed on device. Provide comma separated values for multiple versions
- `device_group` [string] (Alias: Group) - ID of the parent device group. Provide comma separated values for multiple groups
- `device_status` [string] (Alias: DeviceStatus) - Device status. Values: SECURE, AT_RISK, COMPROMISED, NOT_COMPUTED
- `device_type` [string] (Alias: DeviceType) - OS type of the device. Values: WORKSTATION, SERVER, MOBILE
- `name` [string] (Alias: computername) - Name of the device. Provide comma separated values for multiple names
- `ipv4_address` [string] (Alias: IPv4) - IPv4 address of a device
- `is_virtual` [switch] - Filter for virtual machines
- `offset` [int] - Offset parameter for pagination

**Examples:**
```powershell
# Get all devices (very slow for large environments)
Get-SEPCloudDevice

# Get specific computer by name
Get-SEPCloudDevice -Computername "MyComputer"

# Get devices with specific client versions
Get-SEPCloudDevice -client_version "14.2.1031.0100,14.2.770.0000"

# Get devices from specific groups
Get-SEPCloudDevice -device_group "Fmp5838YRsyElHM27PdZww,123456789"

# Get devices with AT_RISK status
Get-SEPCloudDevice -device_status "AT_RISK"

# Get workstations with specific client version
Get-SEPCloudDevice -Client_version "14.3.9681.7000" -device_type "WORKSTATION"

# Get devices by IPv4 address
Get-SEPCloudDevice -IPv4 "192.168.1.1"
```

---

### Get-SEPCloudDeviceDetails

**Synopsis:** Gathers device details from the SEP Cloud console

**Description:** Gathers detailed information for a specific device from the SEP Cloud console.

**Parameters:**
- `device_id` [string] (Alias: id) - ID used to lookup a unique computer

**Outputs:** PSObject

**Examples:**
```powershell
# Get detailed device information
Get-SEPCloudDeviceDetails -id "wduiKXDDSr2CVrRaqrFKNx"
```

**Link:** https://github.com/Douda/PSSymantecCloud

---

### Get-SEPCloudGroup

**Synopsis:** Gathers list of device groups from SEP Cloud

**Description:** Gathers list of device groups from SEP Cloud. Does not contain device information.

**Parameters:**
- `offset` [int] (Alias: api_page) - Page number to query. Defaults to 0. Used for pagination

**Examples:**
```powershell
# Get all device groups
Get-SEPCloudGroup

# Get groups with pagination
Get-SEPCloudGroup -offset 10
```

---

### Get-SEPCloudGroupPolicies

**Synopsis:** Gathers list of policies applied for a device group

**Description:** Gathers list of policies applied for a specific device group.

**Parameters:**
- `group_id` [string] (Alias: groupID) - ID of device group

**Examples:**
```powershell
# Get policies for a specific group
Get-SEPCloudGroupPolicies -GroupID "Fmp5838YRsyElHM27PdZxx"
```

**Link:** https://github.com/Douda/PSSymantecCloud

---

### Move-SEPCloudDevice

**Synopsis:** Moves one or many devices to a different group

**Description:** Moves one or many devices to a different group. Requires group ID and device ID. Does not support device name or group name. Use Get-SEPCloudDevice to get device ID and Get-SEPCloudGroup to get group ID.

**Parameters:**
- `groupId` [string] - The group ID to move the device to
- `deviceId` [string[]] (Alias: device_uids) - The device ID(s) to move (max: 200 devices per call)

**Examples:**
```powershell
# Move single device to a different group
Move-SEPCloudDevice -GroupID "tqrSman3RyqFFd1EqLlZZA" -DeviceID "f3teVmApQlya8XJvEf-wpw"

# Move multiple devices to a group
$deviceList = @('123', '456', '789')
Move-SEPCloudDevice -groupId "I5tExK6hQfC-cnUXk1Siug" -deviceId $deviceList
```

**Link:** https://github.com/Douda/PSSymantecCloud

---

### Start-SEPCloudFullScan

**Synopsis:** Initiate a full scan command on SEP Cloud managed devices

**Description:** Initiate a full scan command on SEP Cloud managed devices. Device ID can be gathered from Get-SEPCloudDevice.

**Parameters:**
- `device_ids` [string[]] (Alias: deviceId) - Array of device IDs
- `org_unit_ids` [string[]] (Alias: orgId) - Organization unit IDs
- `is_recursive` [switch] (Alias: recursive) - Recursive operation switch

**Examples:**
```powershell
# Initiate full scan on specific device
Start-SEPCloudFullScan -device_ids "u7IcxqPvQKmH47MPinPsFw"

# Initiate full scan with organization unit
Start-SEPCloudFullScan -org_unit_ids "org123" -is_recursive
```

---

### Start-SEPCloudQuickScan

**Synopsis:** Initiate a quick scan command on SEP Cloud managed devices

**Description:** Initiate a quick scan command on SEP Cloud managed devices.

**Parameters:**
- `device_ids` [string[]] (Alias: deviceId) - Array of device IDs
- `org_unit_ids` [string[]] (Alias: orgId) - Organization unit IDs
- `is_recursive` [switch] (Alias: recursive) - Recursive operation switch

**Examples:**
```powershell
# Initiate quick scan on specific computer
Start-SEPCloudQuickScan -ComputerName "MyComputer"

# Initiate quick scan using device ID
Start-SEPCloudQuickScan -device_ids "u7IcxqPvQKmH47MPinPsFk"
```

---

### Start-SEPCloudDefinitionUpdate

**Synopsis:** Initiate a definition update request command on SEP Cloud managed devices

**Description:** Initiate a definition update request command on SEP Cloud managed devices to update virus definitions.

**Parameters:**
- `device_ids` [string[]] (Alias: deviceId) - Array of device ids for which to initiate a definition update request
- `org_unit_ids` [string[]] (Alias: orgId) - Organization unit IDs
- `is_recursive` [switch] (Alias: recursive) - Recursive operation switch

**Examples:**
```powershell
# Update definitions on specific device
Start-SEPCloudDefinitionUpdate -deviceId "u7IcxqPvQKmH47MPinPsFw"

# Update definitions recursively on organization unit
Start-SEPCloudDefinitionUpdate -org_unit_ids "org123" -is_recursive
```

**Link:** https://github.com/Douda/PSSymantecCloud

---

## 📋 Policy Management

### Get-SEPCloudPolicesSummary

**Synopsis:** Provides a list of all SEP Cloud policies

**Description:** Provides a summary list of all SEP Cloud policies with optional filtering capabilities.

**Parameters:**
- `limit` [int] - The number of records fetched in a given request (max: 1000)
- `offset` [int] - When this field is not present, it returns the first page
- `name` [string] - The name of the policy you want to search for
- `type` [string] - The type of policy you want to search for

**Examples:**
```powershell
# Get all policies
Get-SEPCloudPolicesSummary

# Get specific policy by name
Get-SEPCloudPolicesSummary -name "My Exploit Protection Policy"

# Get policies by type
Get-SEPCloudPolicesSummary -type "Exploit Protection"

# Get limited number of policies
Get-SEPCloudPolicesSummary -limit 50 -offset 10
```

**Link:** https://github.com/Douda/PSSymantecCloud

---

### Get-SEPCloudPolicyDetails

**Synopsis:** Gathers detailed information on SEP Cloud policy

**Description:** Gathers detailed configuration information for a specific SEP Cloud policy version.

**Parameters:**
- `policy_uid` [string] - Policy UID
- `version` [int] - Policy version

**Outputs:** PSObject

**Examples:**
```powershell
# Get detailed policy information
Get-SEPCloudPolicyDetails -policy_uid "12677e90-3909-4e8a-9f4a-327242269a13" -version 1
```

---

### Set-SEPCloudPolicy

**Synopsis:** Apply a SEP Cloud policy to a device group

**Description:** Apply a SEP Cloud policy to a device group. Must include a specific location (also called policy target rule).

**Parameters:**
- `policyName` [string] - Name of the policy to apply
- `policyId` [string] (Alias: policy_uid) - ID of the policy to apply
- `policyVersion` [int] (Alias: version) - Version of the policy to apply (defaults to latest)
- `target_rules` [string] (Alias: location, targetRule) - Location (policy target rule) to apply the policy to (default: "Default")
- `device_group_ids` [string[]] (Alias: deviceGroupId) - Device group ID(s) to apply the policy to
- `override` [bool] - Override parameter (default: $true)

**Examples:**
```powershell
# Apply latest policy version to device group
Set-SEPCloudPolicy -policyName "My Policy" -location "Default" -deviceGroupID "123456"

# Apply specific policy version
Set-SEPCloudPolicy -policyName "My Policy" -location "Default" -deviceGroupID "123456" -version 2

# Apply policy using policy ID
Set-SEPCloudPolicy -policyId "policy-uid-123" -target_rules "Default" -device_group_ids @("group1", "group2")
```

**Link:** https://github.com/Douda/PSSymantecCloud

---

### Remove-SEPCloudPolicy

**Synopsis:** Removes a SEP Cloud policy from a device group

**Description:** Removes a SEP Cloud policy from a device group. Must include a specific location (also called policy target rule).

**Parameters:**
- `policyName` [string] - Name of the policy to remove
- `policyVersion` [int] (Alias: version) - Version of the policy to remove
- `policyId` [string] (Alias: policy_uid) - Policy ID
- `targetRule` [string] (Mandatory, Alias: target_rules, location) - Location (policy target rule) to remove the policy from (default: "Default")
- `deviceGroupId` [string] (Mandatory, Alias: device_group_ids) - Device group ID to remove the policy from

**Outputs:** None

**Examples:**
```powershell
# Remove policy from device group
Remove-SEPCloudPolicy -policyName "My Policy" -location "Default" -deviceGroupId "123456"

# Remove specific policy version
Remove-SEPCloudPolicy -policyId "policy-uid-123" -version 2 -targetRule "Default" -deviceGroupId "123456"
```

**Link:** https://github.com/Douda/PSSymantecCloud

---

### Update-AllowListPolicyByFileHash

**Synopsis:** Add a process exception to the allow list policy

**Description:** Add a process exception to the allow list policy by file hash.

**Parameters:**
- `policy_uid` [string] - Policy UID
- `version` [int] - Policy version
- `policy_name` [string] - The name of the allow list policy
- `sha2` [string] (Mandatory) - The SHA-256 hash of the file (must be 64-character hexadecimal string)
- `name` [string] - The name of the file

**Examples:**
```powershell
# Add file exception by hash to latest policy version
Update-AllowListPolicyByFileHash -policy_name "My Allow List Policy" -sha2 "366F3DF4774625375BCA2F4D4BEA118A0F661105B09B71219DBF79CBFB5E17B8" -name "test.exe"

# Add file exception to specific policy version
Update-AllowListPolicyByFileHash -policy_uid "policy-123" -version 2 -sha2 "366F3DF4774625375BCA2F4D4BEA118A0F661105B09B71219DBF79CBFB5E17B8" -name "test.exe"
```

---

### Update-AllowListPolicyByFileName

**Synopsis:** Add a filename to the allow list policy

**Description:** Add a filename to the allow list policy. By default enables the exception of scheduled & manual scans for AutoProtect & Behavioral Analysis technologies.

**Parameters:**
- `policy_uid` [string] - Policy UID
- `version` [int] - Policy version
- `policy_name` [string] - Policy name
- `pathvariable` [string] - Path variable with predefined values like [NONE], [PROGRAM_FILES], etc. (default: "[NONE]")
- `path` [string] (Mandatory) - File path
- `scheduled` [bool] - Boolean for scheduled scans (default: $true)
- `features` [string[]] - Array of features: "AUTO_PROTECT", "BEHAVIORAL_ANALYSIS", "TAMPER_PROTECTION", "DEVICE_CONTROL", "ADAPTIVE_ISOLATION" (default: @("AUTO_PROTECT", "BEHAVIORAL_ANALYSIS"))

**Examples:**
```powershell
# Add file exception with default settings
Update-AllowListPolicyByFileName -policy_name "my Allow List Policy" -path "C:\test\exception.exe"

# Add file exception with all features
$featuresList = @("AUTO_PROTECT", "BEHAVIORAL_ANALYSIS", "TAMPER_PROTECTION", "DEVICE_CONTROL", "ADAPTIVE_ISOLATION")
Update-AllowListPolicyByFileName -policy_uid "12345678-1234-1234-1234-123456789123" -version "1" -path "C:\test\exception.exe" -features $featuresList

# Add file exception to latest version with all features
$featuresList = @("AUTO_PROTECT", "BEHAVIORAL_ANALYSIS", "TAMPER_PROTECTION", "DEVICE_CONTROL", "ADAPTIVE_ISOLATION")
Update-AllowListPolicyByFileName -policy_uid "12345678-1234-1234-1234-123456789123" -path "C:\test\exception.exe" -features $featuresList
```

---

## 🛡️ Threat Intelligence

### Get-SEPCloudThreatIntelCveProtection

**Synopsis:** Provide information whether a given CVE has been blocked by any of Symantec technologies

**Description:** Provide information whether a given CVE has been blocked by any of Symantec technologies. These technologies include Antivirus (AV), Intrusion Prevention System (IPS) and Behavioral Analysis & System Heuristics (BASH).

**Parameters:**
- `cve` [string] (Mandatory, Alias: vuln, vulnerability) - Specify one or many CVE to check (accepts pipeline input)

**Examples:**
```powershell
# Check single CVE protection status
Get-SEPCloudThreatIntelCveProtection -cve "CVE-2023-35311"

# Check multiple CVEs using pipeline
"CVE-2023-35311","CVE-2023-35312" | Get-SEPCloudThreatIntelCveProtection
```

**Link:** https://github.com/Douda/PSSymantecCloud

---

### Get-SEPCloudThreatIntelFileInsight

**Synopsis:** Provide file insight enrichments for a given file

**Description:** Provide file insight enrichments for a given file including reputation, prevalence, and other metadata.

**Inputs:** sha256

**Outputs:** PSObject

**Parameters:**
- `file_sha256` [string] (Mandatory, Alias: sha256) - Specify one or many sha256 hash (accepts pipeline input)

**Examples:**
```powershell
# Get file insights for a specific hash
Get-SEPCloudThreatIntelFileInsight -file_sha256 "eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d"

# Get file insights using pipeline
"eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d" | Get-SEPCloudThreatIntelFileInsight
```

**Link:** https://github.com/Douda/PSSymantecCloud

---

### Get-SEPCloudThreatIntelFileProcessChain

**Synopsis:** Provide topK process lineage enrichment for the provided file sha256

**Description:** Provide topK process lineage enrichment for the provided file sha256, showing execution chains and parent processes.

**Inputs:** sha256

**Outputs:** PSObject

**Parameters:**
- `file_sha256` [string] (Mandatory, Alias: sha256) - Specify one or many sha256 hash (accepts pipeline input)

**Examples:**
```powershell
# Get process chain for a file
$ProcessChain = Get-SEPCloudThreatIntelFileProcessChain -file_sha256 "eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d"

# Get process chain using pipeline
"eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d" | Get-SEPCloudThreatIntelFileProcessChain
```

**Link:** https://github.com/Douda/PSSymantecCloud

---

### Get-SEPCloudThreatIntelFileProtection

**Synopsis:** Provide information whether a given file has been blocked by any of Symantec technologies

**Description:** Provide information whether a given file has been blocked by any of Symantec technologies. These technologies include Antivirus (AV), Intrusion Prevention System (IPS) and Behavioral Analysis & System Heuristics (BASH).

**Inputs:** sha256

**Outputs:** PSObject

**Parameters:**
- `file_sha256` [string] (Mandatory, Alias: sha256) - Specify one or many sha256 hash (accepts pipeline input)

**Examples:**
```powershell
# Check file protection status
Get-SEPCloudThreatIntelFileProtection -file_sha256 "eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d"

# Check multiple files using pipeline
"eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d","eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8e" | Get-SEPCloudThreatIntelFileProtection
```

**Link:** https://github.com/Douda/PSSymantecCloud

---

### Get-SEPCloudThreatIntelFileRelated

**Synopsis:** Provide related file for a given file

**Description:** Provide related files for a given file, showing associated threats and similar files.

**Inputs:** sha256

**Outputs:** PSObject

**Parameters:**
- `file_sha256` [string] (Mandatory, Alias: sha256) - Specify one or many sha256 hash (accepts pipeline input)

**Examples:**
```powershell
# Get related files using pipeline
"eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d" | Get-SEPCloudThreatIntelFileRelated

# Get related files directly
Get-SEPCloudThreatIntelFileRelated -file_sha256 "eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d"
```

**Link:** https://github.com/Douda/PSSymantecCloud

---

### Get-SEPCloudThreatIntelNetworkInsight

**Synopsis:** Provide domain insight enrichments for a given domain

**Description:** Provide domain insight enrichments for a given domain including reputation, categorization, and threat intelligence.

**Inputs:** domain

**Outputs:** PSObject

**Parameters:**
- `domain` [string] (Mandatory, Alias: URL) - Specify one or many domain (accepts pipeline input)

**Examples:**
```powershell
# Get domain insights
Get-SEPCloudThreatIntelNetworkInsight -domain "elblogdeloscachanillas.com.mx/s3sy8rq10/ophn.png"

# Get domain insights using pipeline
"elblogdeloscachanillas.com.mx/s3sy8rq10/ophn.png" | Get-SEPCloudThreatIntelNetworkInsight
```

**Link:** https://github.com/Douda/PSSymantecCloud

---

### Get-SEPCloudThreatIntelNetworkProtection

**Synopsis:** Provide information whether a given URL/domain has been blocked by any of Symantec technologies

**Description:** Provide information whether a given URL/domain has been blocked by any of Symantec technologies. These technologies include Antivirus (AV), Intrusion Prevention System (IPS) and Behavioral Analysis & System Heuristics (BASH).

**Parameters:**
- `network` [string] (Mandatory, Alias: domain, url) - Specify one or many URL/domain to check (accepts pipeline input)

**Outputs:** PSObject

**Examples:**
```powershell
# Check domain protection status
Get-SEPCloudThreatIntelNetworkProtection -domain "nicolascoolman.eu"

# Check domain protection using pipeline
"nicolascoolman.eu" | Get-SEPCloudThreatIntelNetworkProtection
```

**Link:** https://github.com/Douda/PSSymantecCloud

---

## 📊 Incident & Event Management

### Get-SEPCloudIncidents

**Synopsis:** Get list of SEP Cloud incidents

**Description:** Get list of SEP Cloud incidents. Using the LUCENE query syntax, you can customize which incidents to gather.

**Parameters:**
- `start_date` [string] - Beginning date to filter incidents (ISO 8601 format). Start date cannot be older than 30 days
- `end_date` [string] - End date to filter incidents (default: current time, ISO 8601 format)
- `limit` [int] - Maximum number of results per page (default: 15, max: 2000)
- `next` [string] - Starting index for pagination (should start with 0)
- `Include_events` [switch] - Switch to include every events that are part of the context & triggered incident events
- `Query` [string] - Custom Lucene query (example: (state_id: 1 OR state_id: 4 ))

**Inputs:** None

**Outputs:** PSObject containing all SEP incidents

**Examples:**
```powershell
# Get incidents with events
Get-SEPCloudIncidents -Include_Events

# Get incidents with custom query
Get-SEPCloudIncidents -Include_events -Query "state_id: [0 TO 3]"

# Get incidents from last 7 days
$startDate = (Get-Date).AddDays(-7).ToString("yyyy-MM-ddTHH:mm:ss.fffK")
Get-SEPCloudIncidents -start_date $startDate

# Get incidents with pagination
Get-SEPCloudIncidents -limit 50 -next "0"
```

---

### Get-SEPCloudIncidentDetails

**Synopsis:** Gathers details about an open incident

**Description:** Gathers comprehensive details about a specific open incident including timeline, events, and affected devices.

**Parameters:**
- `incidentId` [string] (Alias: incident_id) - ID of incident

**Examples:**
```powershell
# Get detailed incident information
Get-SEPCloudIncidentDetails -incident_ID "21b23af2-ea44-479c-a235-9540082da98f"

# Get incident details using alias
Get-SEPCloudIncidentDetails -incidentId "21b23af2-ea44-479c-a235-9540082da98f"
```

**Link:** https://github.com/Douda/PSSymantecCloud

---

### Get-SEPCloudEvents

**Synopsis:** Get list of SEP Cloud Events. By default it will gather data for past 30 days

**Description:** Get list of SEP Cloud Events. You can use various parameters to filter the results including FileDetection, FullScan, or custom Lucene queries.

**Parameters:**
- `feature_name` [string] - Filters events based on a product feature. You can add a comma separated list of feature_name values
- `product` [string] - The value is SAEP. This represents Symantec Endpoint Security events (default: "SAEP")
- `query` [string] - A custom Lucene query to filter the results (e.g. type_id:8001)
- `start_date` [string] - Beginning date to filter events (default: 29 days ago)
- `end_date` [string] - Ending date to filter events (default: today)
- `next` [string] - Starting index of the record for pagination
- `limit` [int] - Batch size for pagination (default: 1000)

**Examples:**
```powershell
# Get all events (very slow and limited to 10k events)
Get-SEPCloudEvents

# Run custom Lucene query
Get-SEPCloudEvents -Query "type_id:8031 OR type_id:8032 OR type_id:8033"

# Get events for specific feature
Get-SEPCloudEvents -feature_name "AntiVirus,FileDetection"

# Get events with date range
$startDate = (Get-Date).AddDays(-7).ToString("yyyy-MM-ddTHH:mm:ss.fffK")
$endDate = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss.fffK")
Get-SEPCloudEvents -start_date $startDate -end_date $endDate
```

**Link:** https://github.com/Douda/PSSymantecCloud

---

## 🗂️ File & Hash Management

### Block-SEPCloudFile

**Synopsis:** Quarantines one or many files on one or many SEP Cloud managed endpoint

**Description:** Quarantines one or many files on one or many SEP Cloud managed endpoints by file hash.

**Parameters:**
- `device_ids` [string[]] (Alias: deviceId) - The ID of the SEP Cloud managed endpoint to quarantine file(s) from
- `hash` [string] (Alias: sha256) - Hash of the file to quarantine

**Examples:**
```powershell
# Block specific file on specific device
Block-SEPCloudFile -Verbose -device_ids "dGKQS2SyQlCbPjC2VxqO0w" -hash "C4C3115E3A1AF01D6747401AA22AF90A047292B64C4EEFF4D8021CC0CB60B22D"

# Block file on multiple devices
$deviceList = @("device1", "device2", "device3")
Block-SEPCloudFile -device_ids $deviceList -hash "C4C3115E3A1AF01D6747401AA22AF90A047292B64C4EEFF4D8021CC0CB60B22D"
```

**Link:** https://github.com/Douda/PSSymantecCloud

---

### Get-SEPCloudFileHashDetails

**Synopsis:** Returns information whether a given file has been blocked by any Symantec technologies

**Description:** Returns comprehensive information about whether a given file has been blocked by any Symantec technologies and provides detailed file analysis.

**Parameters:**
- `file_hash` [string] (Alias: hash) - Required hash to lookup

**Examples:**
```powershell
# Get file hash details
Get-SEPCloudFileHashDetails -file_hash "eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d"

# Get file hash details using alias
Get-SEPCloudFileHashDetails -hash "eec3f761f7eabe9ed569f39e896be24c9bbb8861b15dbde1b3d539505cd9dd8d"
```

**Link:** https://github.com/Douda/PSSymantecCloud

---

## ⚙️ System Information

### Get-SEPCloudComponentType

**Synopsis:** This API lets you retrieve policy component host-groups, network-adapters(adapter), network-services(Connection), network IPS details

**Description:** This API lets you retrieve policy component information including host-groups, network-adapters, network-services, and network IPS details.

**Parameters:**
- `ComponentType` [string] (Mandatory) - Component Type is one of: 'network-ips', 'host-groups', 'network-adapters', 'network-services'
- `offset` [int] - Offset parameter for pagination
- `limit` [int] - Limit parameter (default: 1000)

**Examples:**
```powershell
# Get network adapters
Get-SEPCloudComponentType -componentType 'network-adapters'

# Get host groups
Get-SEPCloudComponentType -componentType 'host-groups'

# Get network services with pagination
Get-SEPCloudComponentType -componentType 'network-services' -limit 500 -offset 100
```

**Notes:** Information or caveats about the function e.g. 'This function is not supported in Linux'

**Link:** https://github.com/Douda/PSSymantecCloud

---

### Get-SEPCloudEDRDumpsList

**Synopsis:** Gets a list of the SEP Cloud Commands

**Description:** Gets a list of the SEP Cloud Commands. All commands are returned by default.

**Parameters:**
- `next` [string] - The next page of results. Used for pagination
- `limit` [int] - The maximum number of results returned. Used for pagination (default: 25)
- `query` [string] - Query to be used in the search. Uses Lucene syntax. Optional. If not used returns all commands by default

**Examples:**
```powershell
# Get all commands
Get-SEPCloudEDRDumpsList

# Get commands with custom query
Get-SEPCloudEDRDumpsList -query "status:completed"

# Get commands with pagination
Get-SEPCloudEDRDumpsList -limit 50 -next "page-token"
```

**Link:** https://github.com/Douda/PSSymantecCloud

---

### Get-SEPCloudTargetRules

**Synopsis:** Provides a list of all target rules in your SEP Cloud account

**Description:** Provides a list of all target rules in your SEP Cloud account. Formerly known as SEP Location awareness.

**Parameters:**
- `offset` [int] (Alias: api_page) - Offset parameter for pagination

**Outputs:** PSObject

**Examples:**
```powershell
# Get all target rules
Get-SEPCloudTargetRules

# Get target rules with pagination
Get-SEPCloudTargetRules -offset 10
```

---

### Get-SEPCloudFeatureList

**Synopsis:** Retrieve SES enumeration details for your devices like feature names, security status and reason codes

**Description:** Retrieve SES enumeration details for your devices including feature names, security status and reason codes.

**Parameters:** None

**Inputs:** None

**Outputs:** PSObject

**Examples:**
```powershell
# Get all feature lists and enumeration details
Get-SEPCloudFeatureList
```

---

## 📚 Additional Information

### Data Retention
- **Important**: Broadcom stores all data for a maximum of 30 days
- Plan your queries and data collection accordingly
- Historical data beyond 30 days is not available

### API Rate Limits
- Respect API rate limits to avoid throttling
- Implement appropriate delays between bulk operations
- Monitor API response headers for rate limit information

### Pagination
- Most commands that return lists support automatic pagination
- Use `limit` and `offset` parameters to control pagination
- Large datasets are automatically paginated by the module

### Lucene Query Syntax
Many commands support Lucene query syntax for advanced filtering:
- Use operators: `AND`, `OR`, `NOT`
- Range queries: `[0 TO 3]`
- Wildcard searches: `name:*computer*`
- Field-specific searches: `type_id:8001`

### Security Considerations
- Store credentials securely using the built-in encryption
- Use `-WhatIf` parameter to preview changes
- Implement least-privilege access for API applications
- Regular token refresh and validation

---

*For the most current information, use `Get-Help <CommandName> -Full` or refer to the official Symantec API documentation.*