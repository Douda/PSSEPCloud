# PSScriptAnalyzer Issues to Fix

## Overview

This document tracks all PSScriptAnalyzer violations identified in the GitHub Actions CI/CD pipeline that are causing test failures. These issues must be resolved for the pipeline to pass quality gates and complete successfully.

**Impact**: Currently blocking GitHub Actions workflows from completing successfully.  
**Priority**: High - these issues prevent proper CI/CD execution and test result publishing.

## Critical Issues (Blocking CI/CD)

### ✅ ShouldProcess Violations - COMPLETED
Functions with state-changing verbs must support `-WhatIf` and `-Confirm` parameters.

**Status**: All 8 functions have been fixed with proper ShouldProcess implementation and tested successfully.
**Implementation**: Added `[CmdletBinding(SupportsShouldProcess)]` to function definitions and implemented `$PSCmdlet.ShouldProcess()` calls for actual state-changing operations.

#### Private Functions:

##### Category 1: Pure Helper Functions (Add SupportsShouldProcess Only)
These functions don't actually change system state but have "New" verbs that PSScriptAnalyzer flags:

- [x] **New-BodyString.ps1** - Function 'New-BodyString' has verb that could change system state
  - [x] Add `[CmdletBinding(SupportsShouldProcess)]` parameter block
  - [x] No ShouldProcess calls needed (builds data structures only)
  - [x] Test: Verify function works with -WhatIf parameter ✅
  
- [x] **New-QueryString.ps1** - Function 'New-QueryString' has verb that could change system state
  - [x] Add `[CmdletBinding(SupportsShouldProcess)]` parameter block
  - [x] No ShouldProcess calls needed (builds URI strings only)
  - [x] Test: Verify function works with -WhatIf parameter ✅
  
- [x] **New-QueryURI.ps1** - Function 'New-QueryURI' has verb that could change system state
  - [x] Add `[CmdletBinding(SupportsShouldProcess)]` parameter block
  - [x] No ShouldProcess calls needed (constructs URIs only)
  - [x] Test: Verify function works with -WhatIf parameter ✅
  
- [x] **New-URIQuery.ps1** - Function 'New-URIQuery' has verb that could change system state
  - [x] Add `[CmdletBinding(SupportsShouldProcess)]` parameter block
  - [x] No ShouldProcess calls needed (builds URIs only)
  - [x] Test: Verify function works with -WhatIf parameter ✅
  
- [x] **New-URIString.ps1** - Function 'New-URIString' has verb that could change system state
  - [x] Update existing `[CmdletBinding()]` to `[CmdletBinding(SupportsShouldProcess)]`
  - [x] No ShouldProcess calls needed (builds URIs only)
  - [x] Test: Verify function works with -WhatIf parameter ✅
  
- [x] **New-UserAgentString.ps1** - Function 'New-UserAgentString' has verb that could change system state
  - [x] Add `[CmdletBinding(SupportsShouldProcess)]` parameter block
  - [x] No ShouldProcess calls needed (generates strings only)
  - [x] Test: Verify function works with -WhatIf parameter ✅

##### Category 2: State-Changing Functions (Add SupportsShouldProcess + Implement Calls)
These functions actually change system state and need full ShouldProcess implementation:

- [x] **Remove-SEPCloudToken.ps1** - Function 'Remove-SEPCloudToken' has verb that could change system state
  - [x] Update existing `[cmdletBinding()]` to `[CmdletBinding(SupportsShouldProcess)]` 
  - [x] Add ShouldProcess call before `Remove-Item` operation (line 29)
    ```powershell
    if ($PSCmdlet.ShouldProcess($script:configuration.CachedTokenPath, "Remove cached token file")) {
        Remove-Item $script:configuration.CachedTokenPath -Force
    }
    ```
  - [x] Add ShouldProcess call before token removal (lines 23-24)
    ```powershell
    if ($PSCmdlet.ShouldProcess("SEP Cloud Connection", "Remove access token")) {
        $script:SEPCloudConnection | Add-Member -MemberType NoteProperty -Name AccessToken -Value $null -Force -ErrorAction SilentlyContinue
        $script:configuration | Add-Member -MemberType NoteProperty -Name AccessToken -Value $null -Force -ErrorAction SilentlyContinue
    }
    ```
  - [x] Test: Verify -WhatIf shows intended actions without executing ✅
  - [x] Test: Verify -Confirm prompts for confirmation ✅
  
- [x] **Set-ObjectTypeName.ps1** - Function 'Set-ObjectTypeName' has verb that could change system state
  - [x] Add `[CmdletBinding(SupportsShouldProcess)]` parameter block
  - [x] Add ShouldProcess call before modifying object TypeNames (line 24)
    ```powershell
    if ($PSCmdlet.ShouldProcess($_.GetType().Name, "Set object type name to '$typename'")) {
        $_.PSObject.TypeNames.Insert(0, $typename)
    }
    ```
  - [x] Test: Verify -WhatIf shows intended type name changes ✅
  - [x] Test: Verify -Confirm prompts for each object modification ✅

#### Implementation Notes:
- **Category 1 functions** only need the parameter declaration to satisfy PSScriptAnalyzer
- **Category 2 functions** need both parameter declaration and actual ShouldProcess implementation
- All functions should maintain backward compatibility
- Test with both `-WhatIf` and `-Confirm` parameters after implementation

### 🐛 Empty Catch Blocks
Empty catch blocks should use `Write-Error` or `throw` statements.

- [ ] **New-UserAgentString.ps1:41** - Empty catch block needs proper error handling
- [ ] **New-UserAgentString.ps1:74** - Empty catch block needs proper error handling

### ⚠️ Deprecated WMI Usage
WMI cmdlets should be replaced with CIM cmdlets for PowerShell 3.0+ compatibility.

- [ ] **New-UserAgentString.ps1:37** - Replace `Get-WmiObject` with `Get-CimInstance`

### 📝 Unused Variables
Variables that are assigned but never used should be removed or utilized.

- [ ] **New-UserAgentString.ps1:87** - Variable 'StringBuilder' assigned but never used

### 📚 Plural Noun Violations
PowerShell cmdlets should use singular nouns per naming conventions.

#### Public Functions:
- [ ] **Get-SEPCloudDeviceDetails.ps1** - Uses plural noun 'Details' (consider 'Get-SEPCloudDeviceDetail')
- [ ] **Get-SEPCloudEvents.ps1** - Uses plural noun 'Events' (consider 'Get-SEPCloudEvent')
- [ ] **Get-SEPCloudFileHashDetails.ps1** - Uses plural noun 'Details' (consider 'Get-SEPCloudFileHashDetail')
- [ ] **Get-SEPCloudGroupPolicies.ps1** - Uses plural noun 'Policies' (consider 'Get-SEPCloudGroupPolicy')
- [ ] **Get-SEPCloudIncidentDetails.ps1** - Uses plural noun 'Details' (consider 'Get-SEPCloudIncidentDetail')
- [ ] **Get-SEPCloudIncidents.ps1** - Uses plural noun 'Incidents' (consider 'Get-SEPCloudIncident')

## Implementation Guidelines

### Code Standards
- Follow PowerShell best practices and naming conventions
- Maintain backward compatibility where possible for public functions
- Add proper error handling instead of empty catch blocks
- Use modern PowerShell cmdlets (CIM vs WMI)

### Testing Requirements
- Verify PSScriptAnalyzer passes with PSGallery settings
- Ensure all existing tests continue to pass
- Test both PowerShell 5.1 and 7.x compatibility

### File Modification Approach
1. **Private Functions**: Can be modified directly (internal use only)
2. **Public Functions**: Consider aliases for backward compatibility if renaming
3. **Error Handling**: Replace empty catch blocks with meaningful error messages
4. **Modern Cmdlets**: Update WMI usage to CIM equivalents

## Progress Tracking

### Priority Levels
- **🔴 Critical**: Blocking CI/CD pipeline (ShouldProcess, Empty Catch, WMI)
- **🟡 Important**: Code quality standards (Unused Variables, Plural Nouns)

### Estimated Effort
- **Low**: Simple parameter additions (ShouldProcess)
- **Medium**: Error handling improvements, cmdlet replacements
- **High**: Function renaming with backward compatibility

### Dependencies
- Fix critical issues first to unblock CI/CD pipeline
- Test individual fixes before proceeding to next items
- Ensure no breaking changes to public API

## Current Status
- **Total Issues**: 17 violations identified
- **Critical Issues**: 11 (blocking CI/CD)
- **Quality Issues**: 6 (best practices)
- **ShouldProcess Issues**: 8/8 (100% ✅ COMPLETED)
- **Empty Catch Blocks**: 0/2 (0%)
- **Deprecated WMI Usage**: 0/1 (0%)
- **Unused Variables**: 0/1 (0%)
- **Plural Noun Violations**: 0/6 (0%)
- **Overall Completion**: 8/17 (47%)

---
*This document will be updated as issues are resolved and new ones are identified.*