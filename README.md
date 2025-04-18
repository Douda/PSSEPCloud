# PSSEPCloud

This PowerShell module provides a series of cmdlets to interact with the [Symantec Endpoint Protection Cloud REST API](https://apidocs.securitycloud.symantec.com/#/doc?id=ses_auth)

To interact with the SEP on-premise version API, you can use [PSSymantecSEPM](https://github.com/Douda/PSSymantecSEPM) module instead

[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/PSSEPCloud?style=flat-square)](https://www.powershellgallery.com/packages/PSSEPCloud)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/PSSEPCloud?style=flat-square)](https://www.powershellgallery.com/packages/PSSEPCloud)
![GitHub](https://img.shields.io/github/license/Douda/PSSEPCloud?style=flat-square)

## Overview
This small project is an attempt to interact with the Symantec/Broadcom API to manage 

- Symantec Endpoint Protection (SEP) Cloud 
- [Symantec Endpoint Security](https://SEP.securitycloud.symantec.com/v2/home/dashboard) (SES) Platform.

To interact with your SEP Cloud platform you need to 
- Create an [integration application](https://techdocs.broadcom.com/us/en/symantec-security-software/endpoint-security-and-management/endpoint-security/sescloud/Settings/creating-a-client-application-v132702110-d4152e4057.html) and get your ClientID & Secret from your [Symantec Cloud Platform](https://SEP.securitycloud.symantec.com/v2/home/dashboard)
- Generate your [authentication token](https://apidocs.securitycloud.symantec.com/#/doc?id=ses_auth) (Go to SES > Generating your token bearer)


This module follows the [Module Builder Project](https://github.com/PoshCode/ModuleBuilder) folder structure for easy maintenance and versioning


## Installation
2 ways to install this module :
- Via [Powershell Gallery](https://www.powershellgallery.com/packages/PSSEPCloud/) 
```PowerShell
Install-Module PSSEPCloud
```
- Build it from sources (See [Building your module](##Building-your-module))

## List of commands
```PowerShell
PS C:\PSSEPCloud> Get-Command -Module PSSEPCloud | Select-Object -Property Name

Block-SEPCloudFile
Clear-SEPCloudAuthentication
Connect-SEPCloud
Remove-SEPCloudPolicy
Move-SEPCloudDevice
Get-Something
Get-SEPCloudToken
Get-SEPCloudThreatIntelNetworkProtection
Get-SEPCloudThreatIntelNetworkInsight
Get-SEPCloudThreatIntelFileRelated
Get-SEPCloudThreatIntelFileProtection
Get-SEPCloudThreatIntelFileProcessChain
Get-SEPCloudThreatIntelFileInsight
Get-SEPCloudThreatIntelCveProtection
Get-SEPCloudTargetRules
Get-SEPCloudPolicyDetails
Get-SEPCloudPolicesSummary
Get-SEPCloudIncidents
Get-SEPCloudIncidentDetails
Get-SEPCloudGroupPolicies
Get-SEPCloudGroup
Get-SEPCloudFileHashDetails
Get-SEPCloudFeatureList
Get-SEPCloudEvents
Get-SEPCloudEDRDumpsList
Get-SEPCloudDeviceDetails
Get-SEPCloudDevice
Get-SEPCloudComponentType
Start-SEPCloudDefinitionUpdate
Set-SEPCloudPolicy
Start-SEPCloudFullScan
Start-SEPCloudQuickScan
```

For detailed information about each command, use `Get-Help <command> -Full`

### Authentication
Generate your authentication token via your [SEP Cloud console integration menu](https://SEP.securitycloud.symantec.com/v2/integration/client-applications) and keep your ClientID & Secret

### Examples
Connect to the API via the approate Cmd-let

```PowerShell
PS C:\PSSEPCloud> Connect-SEPCloud
```

#### Devices
```PowerShell
# list of all your devices
# Handles pagination (can be slow on big environments)
PS C:\PSSEPCloud> $devices = Get-SEPCloudDevice
```

```PowerShell
# list of all your devices that are considered "SECURE", "AT_RISK", or "COMPROMISED"
PS C:\PSSEPCloud> $devicesAtRisk = Get-SEPCloudDevice -Device_Status "AT_RISK"
```

```PowerShell
# Get details from a specific device
PS C:\PSSEPCloud> $MyComputerDetails = Get-SEPCloudDevice -Computername MyComputer

id                       : abcdefghijkl
name                     : MyComputer
host                     : MyComputer
domain                   : contoso.com
created                  : 10/10/2022 11:47:44
modified                 : 19/07/2023 21:57:27
os                       : @{ver=10.0.19045; name=Windows 10 Enterprise Edition; type=WINDOWS_WORKSTATION; 64_bit=True; lang=fr; major_ver=10; minor_ver=0; sp=0; tz_offset=60; user=first.last; user_domain=CONTOSO.COM; vol_avail_mb=93037; vol_cap_mb=241126}
hw                       : @{uuid=XXXXXXX-E406-5392-66BC-B3AEE4BC9185; bios_ver=ACER - 12F0 R1CET66W(1.35 ); cpu_mhz=2096; cpu_type=AMD64 Family 23 Model 96 Stepping 1; log_cpus=12; mem_mb=15592...}
adapters                 : {@{addr=74:4C:A1:B5:C9:0D; category=Public; ipv4Address=192.168.128.20; ipv4_gw=192.168.128.1; ipv4_prefix=24; mask=255.255.255.0}}
is_virtual               : False
dns_names                : {192.168.1.1…}
parent_device_group_id   : XXXX-KeUTx2ao0zIr0fpyA
parent_device_group_name : Workstations
device_status            : SECURE
connection_status        : ONLINE
```
```PowerShell
# Get detailed info from an asset using device_ID
$deviceDetails = Get-SEPCloudDeviceDetails -Device_ID abcdefghijkl
```
#### Incidents

```PowerShell
# list of all your incidents
PS C:\PSSEPCloud> $incidents = Get-SEPCloudIncidents
```

```PowerShell
# list of all your incidents, including all events
PS C:\PSSEPCloud> $incidentsWithEvents = Get-SEPCloudIncidents -Include_Events
```
**Note**: Broadcom stores all data for a maximum of 30 days

Get a custom list of incidents based on a specific query, using supported [Lucene query language](https://techdocs.broadcom.com/us/en/symantec-security-software/endpoint-security-and-management/endpoint-detection-and-response/4-5/about-the-ways-to-search-for-indicators-of-comprom-v115770112-d38e14827/search-query-syntax-v124335086-d38e19040.html). 

```PowerShell
# Example : different incident states : 0 Unknown | 1 New | 2 In Progress | 3 On Hold | 4 Resolved | 5 Closed
PS C:\PSSEPCloud> $incidentsOpened = Get-SEPCloudIncidents -Include_events -Query "state_id: [0 TO 3]"
```

#### Threat Intel
The Protection APIs provide information whether a given file, domain or CVE has been blocked by any of Symantec technologies

file coverage
```PowerShell
PS C:\PSSEPCloud> Get-SEPThreatIntelFileProtection -file_sha256 64c731adbe1b96cb5765203b1e215093dcf268d020b299445884a4ae62ed2d3a | fl

file  : 64c731adbe1b96cb5765203b1e215093dcf268d020b299445884a4ae62ed2d3a
state : {@{technology=AntiVirus; firstDefsetVersion=20160428.021; threatName=Trojan.Gen.2}, @{technology=Intrusion Prevention System; firstDefsetVersion=20221025.061; threatName=System Infected: Trojan.Backdoor Activity 634},
        @{technology=Behavioural Analysis & System Heuristics; firstDefsetVersion=20230420.001; threatName=SONAR.SuspScr!gen1}}
```
domain coverage
```PowerShell
PS C:\PSSEPCloud> Get-SEPThreatIntelNetworkProtection -domain nicolascoolman.eu | fl

network : nicolascoolman.eu
state   : {@{technology=AntiVirus; firstDefsetVersion=2023.03.14.024; threatName=WS.Reputation.1}, @{technology=Behavioural Analysis & System Heuristics; firstDefsetVersion=20230301.001; threatName=SONAR.Heur.Dropper}}
```

CVE coverage
```PowerShell
PS C:\PSSEPCloud> Get-SEPThreatIntelCveProtection -cve CVE-2023-35311 | fl

cve   : CVE-2023-35311
state : {@{technology=Intrusion Prevention System; firstDefsetVersion=20230712.061; threatName=Web Attack: Microsoft Outlook CVE-2023-35311}}
```


#### Policies
```PowerShell
# List of all policies
PS C:\PSSEPCloud> $policiesSUmmary = Get-SEPCloudPolicesSummary

total policies
----- --------
  111 {@{name=Block USB Device Control Policy; author=Aurelien Boumanne; policy_uid=xxxxxxx...
```

```PowerShell
# Get policy details for a specific version
PS C:\PSSEPCloud> $policyMyPolicyV5 = Get-SEPCloudPolicyDetails -Name "My Policy" -Version 5
```
**Note**: By default, will output the latest version

## Building your module
This PS module is built with Sampler. You can build the module yourself using the [Sampler workflow](https://github.com/gaelcolas/Sampler#how-to-set-up-the-build-environment-in-the-current-powershell-session)
```PowerShell
# Install required module ModuleBuilder
Install-Module -Name Sampler

# Clone the PSSEPCloud repository
git clone https://github.com/Douda/PSSEPCloud
cd PSSEPCloud

# Build PSSEPCloud module
./build.ps1

# Load the module (based on version)
Import-Module .\Output\PSSEPCloud\x.x.x\PSSEPCloud.ps1m -Force
```
