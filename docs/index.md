# PSSEPCloud Documentation

Welcome to the comprehensive documentation for the **PSSEPCloud** PowerShell module - your gateway to managing Symantec Endpoint Protection Cloud environments through PowerShell.

## 🚀 Quick Start

**PSSEPCloud** is a PowerShell module that provides a robust API wrapper for the Symantec Endpoint Protection Cloud REST API, enabling administrators to manage their SEP Cloud environments programmatically.

### Installation
```powershell
Install-Module PSSEPCloud
```

### Basic Usage
```powershell
# Set your region
Set-SEPCloudRegion -Region "North America"

# Connect to SEP Cloud
Connect-SEPCloud

# Get all devices
$devices = Get-SEPCloudDevice
```

## 📚 Documentation Sections

### 📖 [Complete Module Guide](guide.md)
Comprehensive guide covering:
- **Module Architecture**: Understanding the structure and design patterns
- **Installation Methods**: Multiple installation approaches
- **Configuration**: Setting up regions and authentication
- **Core Concepts**: API data repository pattern, authentication architecture
- **Development**: Building, testing, and contributing
- **Best Practices**: Security, performance, and error handling

### 🛠️ [Command Reference](commands.md)
Detailed documentation for all PowerShell commands:
- **Synopsis**: Brief description of each command
- **Parameters**: Complete parameter documentation
- **Examples**: Real-world usage scenarios
- **Return Types**: Expected output formats
- **Related Commands**: Cross-references to related functionality

## 🔧 Module Categories

### 🔐 Authentication & Connection
Establish secure connections to SEP Cloud with multi-region support:
- `Connect-SEPCloud`: Primary connection establishment
- `Get-SEPCloudToken`: Token management and refresh
- `Set-SEPCloudRegion`: Region configuration (Americas, Europe, India)
- `Clear-SEPCloudAuthentication`: Credential cleanup

### 💻 Device Management
Comprehensive device lifecycle management:
- `Get-SEPCloudDevice`: Device discovery and listing
- `Get-SEPCloudDeviceDetails`: Detailed device information
- `Get-SEPCloudGroup`: Device group management
- `Move-SEPCloudDevice`: Device group transfers
- `Start-SEPCloudFullScan`: Full system scans
- `Start-SEPCloudQuickScan`: Quick security scans
- `Start-SEPCloudDefinitionUpdate`: Definition updates

### 📋 Policy Management
Centralized policy administration:
- `Get-SEPCloudPolicesSummary`: Policy overview
- `Get-SEPCloudPolicyDetails`: Detailed policy configuration
- `Set-SEPCloudPolicy`: Policy application
- `Remove-SEPCloudPolicy`: Policy removal
- `Update-AllowListPolicyByFileHash`: File hash allowlisting
- `Update-AllowListPolicyByFileName`: File name allowlisting

### 🛡️ Threat Intelligence
Advanced threat analysis and protection:
- `Get-SEPCloudThreatIntelCveProtection`: CVE protection status
- `Get-SEPCloudThreatIntelFileInsight`: File reputation analysis
- `Get-SEPCloudThreatIntelFileProcessChain`: Process chain analysis
- `Get-SEPCloudThreatIntelNetworkInsight`: Network threat intelligence
- `Block-SEPCloudFile`: Global file blocking

### 📊 Incident & Event Management
Security incident response and monitoring:
- `Get-SEPCloudIncidents`: Security incident management
- `Get-SEPCloudIncidentDetails`: Detailed incident analysis
- `Get-SEPCloudEvents`: Security event monitoring
- `Get-SEPCloudFileHashDetails`: File hash investigation

### ⚙️ System Information
Environment discovery and configuration:
- `Get-SEPCloudComponentType`: Component type enumeration
- `Get-SEPCloudEDRDumpsList`: EDR memory dump management
- `Get-SEPCloudTargetRules`: Targeting rule configuration
- `Get-SEPCloudFeatureList`: Feature availability

## 🏗️ Architecture Overview

### Centralized API Management
The module uses a centralized API data repository pattern through the `Get-SEPCloudAPIData` function, which provides:
- **Endpoint Definitions**: Complete API endpoint specifications
- **Parameter Mappings**: Request/response structure definitions
- **Version Management**: API version compatibility
- **Object Type Mapping**: PowerShell object type assignments

### Cross-Platform Support
- **Windows PowerShell 5.1**: Legacy environment compatibility
- **PowerShell 7.x**: Modern cross-platform support (Windows/Linux)
- **Ubuntu Development**: Primary development and testing environment

### Security Architecture
- **Encrypted Storage**: Credential encryption using PowerShell's CliXml
- **Multi-Region Support**: Americas, Europe, India endpoint support
- **Token Management**: Automatic refresh and validation
- **ShouldProcess**: Built-in `-WhatIf` and `-Confirm` support

## 🔗 API Coverage

The module provides comprehensive coverage of the Symantec Endpoint Security API:

- **[Authentication](https://apidocs.securitycloud.symantec.com/#/doc?id=ses_auth)**: OAuth2 token management
- **[Device Information](https://apidocs.securitycloud.symantec.com/#/doc?id=ses_devicesinfo)**: Device discovery and management
- **[Device Commands](https://apidocs.securitycloud.symantec.com/#/doc?id=ses_devicecommands)**: Remote device operations
- **[Device Groups](https://apidocs.securitycloud.symantec.com/#/doc?id=ses_devicegroupsinfo)**: Group management
- **[Policies](https://apidocs.securitycloud.symantec.com/#/doc?id=ses_policies)**: Policy administration
- **[Threat Intelligence](https://apidocs.securitycloud.symantec.com/#/doc?id=related_api)**: Threat analysis and protection
- **[Incidents](https://apidocs.securitycloud.symantec.com/#/doc?id=insight_api)**: Security incident management
- **[Process Chains](https://apidocs.securitycloud.symantec.com/#/doc?id=process_chain_api)**: Process execution analysis
- **[Protection](https://apidocs.securitycloud.symantec.com/#/doc?id=protection)**: File and network protection

## 📈 Development Status

The module is actively developed following the **Sampler Project** framework:
- **CI/CD Integration**: GitHub Actions for multi-platform testing
- **Quality Assurance**: Comprehensive Pester test coverage
- **Version Control**: GitVersion for semantic versioning
- **Documentation**: Automated help generation and maintenance

## 🤝 Community & Support

### Getting Help
- **Built-in Help**: Use `Get-Help <CommandName> -Full` for detailed documentation
- **GitHub Issues**: Report bugs and request features
- **API Documentation**: Reference the official Symantec API docs
- **Community**: Engage with other users and contributors

### Contributing
- **Code Standards**: Follow existing patterns and conventions
- **Testing**: Include comprehensive Pester tests
- **Documentation**: Update help and documentation
- **Cross-Platform**: Ensure compatibility across supported platforms

## 📜 Quick Reference

### Essential Commands
```powershell
# Connection
Connect-SEPCloud
Set-SEPCloudRegion -Region "North America"

# Device Management
Get-SEPCloudDevice -ComputerName "MyComputer"
Get-SEPCloudDeviceDetails -DeviceId "device-id"

# Policy Management
Get-SEPCloudPolicesSummary
Set-SEPCloudPolicy -PolicyId "policy-id" -DeviceGroupIds @("group-id")

# Threat Intelligence
Get-SEPCloudThreatIntelFileProtection -FileHash "sha256-hash"
Block-SEPCloudFile -FileHash "sha256-hash"

# Incident Management
Get-SEPCloudIncidents
Get-SEPCloudIncidentDetails -IncidentId "incident-id"
```

### Important Notes
- **Data Retention**: Broadcom stores data for maximum 30 days
- **Pagination**: Automatically handled by the module
- **Rate Limits**: Respect API throttling and implement delays
- **Regional Endpoints**: Use appropriate region-specific configurations

---

*This documentation is automatically generated and maintained. For the most current information, please refer to the official API documentation and module help files.*