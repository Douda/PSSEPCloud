# PSSEPCloud Module Guide

## Overview

**PSSEPCloud** is a PowerShell module that provides a comprehensive API wrapper for the [Symantec Endpoint Protection Cloud REST API](https://apidocs.securitycloud.symantec.com/). This module enables PowerShell administrators to interact with Symantec Endpoint Security (SES) Cloud platforms programmatically, supporting both Windows PowerShell 5.1 and PowerShell 7.x on Windows and Linux platforms.

## Key Features

- **Cross-Platform Support**: Works on Windows PowerShell 5.1 and PowerShell 7.x (Windows/Linux)
- **Comprehensive API Coverage**: Supports authentication, device management, policy management, threat intelligence, and incident response
- **Centralized API Management**: Uses a centralized API data repository pattern via `Get-SEPCloudAPIData`
- **Automatic Pagination**: Handles large datasets automatically
- **Secure Authentication**: Encrypted credential storage using PowerShell's CliXml encryption
- **Multi-Region Support**: Supports Americas, Europe, and India regions
- **ShouldProcess Support**: Implements `-WhatIf` and `-Confirm` parameters for safe operations

## Repository Structure

The module follows the [Sampler Project](https://github.com/gaelcolas/Sampler) framework structure for maintainability and best practices:

```
PSSEPCloud/
├── source/                    # Source code
│   ├── Public/               # Public functions (exported)
│   ├── Private/              # Private functions (internal)
│   ├── PSSEPCloud.psd1       # Module manifest
│   ├── PSSEPCloud.psm1       # Module file
│   └── en-US/                # Help documentation
├── tests/                    # Pester tests
│   ├── Unit/Public/          # Public function tests
│   └── Unit/Private/         # Private function tests
├── output/                   # Build output
├── docs/                     # Documentation
├── build.ps1                 # Build script
├── RequiredModules.psd1      # Dependencies
└── .github/workflows/        # CI/CD pipelines
```

## Core Architecture

### API Data Repository Pattern

The module uses a centralized API data repository via the `Get-SEPCloudAPIData` function located in `/source/Private/Get-SEPCloudAPIData.ps1`. This function contains:

- **Endpoint Definitions**: Complete API endpoint specifications
- **HTTP Methods**: GET, POST, PUT, DELETE, PATCH operations
- **Parameter Mappings**: Body and query parameter definitions
- **Response Handling**: Result parsing and object type mapping
- **Versioning**: API version management and selection

### Authentication Architecture

The module implements a secure, multi-session authentication system:

1. **Region Selection**: Set via `Set-SEPCloudRegion` (Americas, Europe, India)
2. **Credential Storage**: Encrypted using `Export-CliXml`/`Import-CliXml`
3. **Token Management**: Automatic token refresh and validation
4. **Session Management**: Global connection object for state management

### Function Categories

#### Authentication & Connection
- `Connect-SEPCloud`: Establish API connection
- `Get-SEPCloudToken`: Retrieve/refresh authentication tokens
- `Set-SEPCloudRegion`: Configure tenant region
- `Clear-SEPCloudAuthentication`: Remove stored credentials

#### Device Management
- `Get-SEPCloudDevice`: Retrieve device information with pagination
- `Get-SEPCloudDeviceDetails`: Get detailed device information
- `Get-SEPCloudGroup`: List device groups
- `Get-SEPCloudGroupPolicies`: Get policies assigned to groups
- `Move-SEPCloudDevice`: Transfer devices between groups
- `Start-SEPCloudFullScan`: Initiate full antivirus scan
- `Start-SEPCloudQuickScan`: Initiate quick scan
- `Start-SEPCloudDefinitionUpdate`: Update virus definitions

#### Policy Management
- `Get-SEPCloudPolicesSummary`: List all policies
- `Get-SEPCloudPolicyDetails`: Get detailed policy configuration
- `Set-SEPCloudPolicy`: Apply policies to device groups
- `Remove-SEPCloudPolicy`: Remove policies from groups
- `Update-AllowListPolicyByFileHash`: Add file hash to allowlist
- `Update-AllowListPolicyByFileName`: Add filename to allowlist

#### Threat Intelligence
- `Get-SEPCloudThreatIntelCveProtection`: CVE protection information
- `Get-SEPCloudThreatIntelFileInsight`: File reputation and insights
- `Get-SEPCloudThreatIntelFileProcessChain`: Process execution chains
- `Get-SEPCloudThreatIntelFileProtection`: File protection status
- `Get-SEPCloudThreatIntelFileRelated`: Related files and threats
- `Get-SEPCloudThreatIntelNetworkInsight`: Network threat intelligence
- `Get-SEPCloudThreatIntelNetworkProtection`: Domain protection status

#### Incident & Event Management
- `Get-SEPCloudIncidents`: List security incidents with pagination
- `Get-SEPCloudIncidentDetails`: Get detailed incident information
- `Get-SEPCloudEvents`: Retrieve security events with pagination
- `Block-SEPCloudFile`: Block files globally

#### System Information
- `Get-SEPCloudComponentType`: List available component types
- `Get-SEPCloudEDRDumpsList`: Get EDR memory dumps
- `Get-SEPCloudTargetRules`: List targeting rules
- `Get-SEPCloudFeatureList`: Get available features
- `Get-SEPCloudFileHashDetails`: Get file hash information

## Installation

### From PowerShell Gallery
```powershell
Install-Module PSSEPCloud
```

### From Source
```powershell
# Clone the repository
git clone https://github.com/Douda/PSSEPCloud
cd PSSEPCloud

# Install dependencies
./build.ps1 -ResolveDependency

# Build the module
./build.ps1

# Import the module
Import-Module ./output/PSSEPCloud/<version>/PSSEPCloud.psd1
```

## Initial Setup

### 1. Create API Application
1. Navigate to your [Symantec Cloud Platform](https://sep.securitycloud.symantec.com/v2/home/dashboard)
2. Go to **Settings** → **Integration** → **Client Applications**
3. Create a new application and note your **Client ID** and **Secret**

### 2. Configure Region
```powershell
# Set your tenant region
Set-SEPCloudRegion -Region "North America"  # or "Europe" or "India"
```

### 3. Authenticate
```powershell
# Connect using interactive authentication
Connect-SEPCloud

# Or provide credentials directly
Connect-SEPCloud -ClientId "your-client-id" -Secret "your-secret"
```

## Common Usage Patterns

### Device Management
```powershell
# Get all devices (handles pagination automatically)
$devices = Get-SEPCloudDevice

# Get specific device by name
$myDevice = Get-SEPCloudDevice -ComputerName "MyComputer"

# Get devices by status
$riskyDevices = Get-SEPCloudDevice -Device_Status "AT_RISK"

# Get detailed device information
$deviceDetails = Get-SEPCloudDeviceDetails -DeviceId "device-id"

# Move device to different group
Move-SEPCloudDevice -DeviceId "device-id" -TargetGroup "group-id"
```

### Policy Management
```powershell
# List all policies
$policies = Get-SEPCloudPolicesSummary

# Get detailed policy information
$policyDetails = Get-SEPCloudPolicyDetails -PolicyId "policy-id"

# Apply policy to device group
Set-SEPCloudPolicy -PolicyId "policy-id" -DeviceGroupIds @("group-id")

# Add file to allowlist
Update-AllowListPolicyByFileHash -PolicyId "policy-id" -FileHash "sha256-hash"
```

### Threat Intelligence
```powershell
# Check file protection status
$fileProtection = Get-SEPCloudThreatIntelFileProtection -FileHash "sha256-hash"

# Get file insights
$fileInsights = Get-SEPCloudThreatIntelFileInsight -FileHash "sha256-hash"

# Check domain protection
$domainProtection = Get-SEPCloudThreatIntelNetworkProtection -Domain "example.com"

# Get CVE protection information
$cveProtection = Get-SEPCloudThreatIntelCveProtection -CveId "CVE-2023-1234"
```

### Incident Management
```powershell
# Get all incidents
$incidents = Get-SEPCloudIncidents

# Get incidents with events
$incidentsWithEvents = Get-SEPCloudIncidents -Include_Events

# Query incidents using Lucene syntax
$openIncidents = Get-SEPCloudIncidents -Query "state_id: [0 TO 3]"

# Get detailed incident information
$incidentDetails = Get-SEPCloudIncidentDetails -IncidentId "incident-id"
```

### Device Commands
```powershell
# Initiate full scan
Start-SEPCloudFullScan -DeviceId "device-id"

# Initiate quick scan
Start-SEPCloudQuickScan -DeviceId "device-id"

# Update definitions
Start-SEPCloudDefinitionUpdate -DeviceId "device-id"

# Block file globally
Block-SEPCloudFile -FileHash "sha256-hash"
```

## Development and Testing

### Build Commands
```powershell
# Build the module
./build.ps1

# Run all tests
./build.ps1 -Tasks test

# Run specific test
./build.ps1 -Tasks test -PesterPath "./tests/Unit/Public/Get-SEPCloudDevice.tests.ps1"

# Install dependencies
./build.ps1 -ResolveDependency
```

### Testing Framework
The module uses **Pester 5.x** for testing with comprehensive coverage:
- **Unit Tests**: Located in `/tests/Unit/`
- **Public Function Tests**: Test all exported functions
- **Private Function Tests**: Test internal helper functions
- **CI/CD Integration**: GitHub Actions for multi-platform testing

### Supported Platforms
- **Ubuntu PowerShell 7.x**: Primary development environment
- **Windows PowerShell 5.1**: Legacy compatibility
- **Windows PowerShell 7.x**: Modern Windows support

## Best Practices

### Security
- Store credentials securely using the built-in encrypted storage
- Use `-WhatIf` parameter to preview changes before execution
- Implement least-privilege access for API applications
- Regular token refresh and validation

### Performance
- Use specific filters to reduce API calls
- Leverage pagination for large datasets
- Cache frequently accessed data when appropriate
- Monitor API rate limits

### Error Handling
- Check connection status before operations
- Handle pagination errors gracefully
- Implement retry logic for transient failures
- Use verbose logging for troubleshooting

## API Rate Limits and Considerations

- **Data Retention**: Broadcom stores data for maximum 30 days
- **Pagination**: Automatically handled by the module
- **Rate Limits**: Respect API rate limits and implement appropriate delays
- **Regional Endpoints**: Use appropriate region-specific endpoints

## Support and Contributions

### Getting Help
- Use `Get-Help <CommandName> -Full` for detailed command documentation
- Check the module's GitHub repository for issues and discussions
- Review the API documentation at [Symantec API Docs](https://apidocs.securitycloud.symantec.com/)

### Contributing
- Follow the existing code patterns and structure
- Include comprehensive Pester tests for new functions
- Update documentation for new features
- Ensure cross-platform compatibility

## Version History

The module uses **GitVersion** for semantic versioning and maintains a comprehensive changelog following the [Keep a Changelog](https://keepachangelog.com/) format.

## License

This module is released under the MIT License. See the LICENSE file for details.