# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PSSEPCloud is a PowerShell module that provides a comprehensive API wrapper for Symantec Endpoint Protection (SEP) Cloud and Symantec Endpoint Security (SES) Platform. It enables administrators to manage Symantec cloud security services through PowerShell cmdlets.

## Core Development Rules

### Code Quality
  - Functions must be focused and small
  - Follow existing patterns exactly
  - Include comprehensive documentation and comments
  - Write tests for every functions

### Testing requierements
  - New features require tests
  - Bug fixes require regression tests

## Pull Requests

- Create a detailed message of what changed. Focus on the high level description of
  the problem it tries to solve, and how it is solved. Don't go into the specifics of the
  code unless it adds clarity.

- NEVER ever mention a `co-authored-by` or similar aspects. In particular, never
  mention the tool used to create the commit message or PR.

## Development Commands

### Build Commands
```powershell
# Build the module
./build.ps1

# Install dependencies
./build.ps1 -ResolveDependency

# Run tests
./build.ps1 -Tasks test

# Run test for a specific  function
./build.ps1 -Tasks test -PesterPath ./tests/Unit/Private/Get-Something.tests.ps1 -CodeCoverageThreshold 0

# Build and package
./build.ps1 -Tasks build

# Publish to gallery
./build.ps1 -Tasks publish
```

### GitHub Actions CI/CD

The project uses GitHub Actions for continuous integration and deployment with **Windows-focused testing**:

#### **Main CI/CD Pipeline** (`.github/workflows/ci-cd.yml`)
**Triggers**: Pushes to `main` branch, version tags, pull requests, manual dispatch

**Build Stage**:
- Uses `windows-latest` runner with GitVersion for semantic versioning
- Runs `./build.ps1 -ResolveDependency -tasks pack`
- Uploads build artifacts for downstream jobs

**Test Stage** (Matrix Strategy):
- **Job 1**: Windows PowerShell 5.1 (`powershell.exe`)
- **Job 2**: PowerShell 7.x on Windows (`pwsh`)
- Both jobs run `./build.ps1 -tasks test -CodeCoverageThreshold 0`
- Publishes NUnit test results and uploads coverage artifacts
- All tests currently pass: 19 passed, 0 failed, 2 skipped

**Deploy Stage** (Production Environment):
- Triggers only on `main` branch or version tags
- Runs `./build.ps1 -tasks publish` for PowerShell Gallery deployment
- Creates changelog pull requests automatically

#### **Pull Request Validation** (`.github/workflows/pr.yml`)
**Quality Assurance Jobs**:
- **Test Validation**: Matrix testing on PS 5.1 and 7.x
- **Code Quality**: PSScriptAnalyzer scan with PSGallery settings
- **Help Documentation**: Validates all public functions have proper help
- **Security Scan**: DevSkim security analysis (currently disabled on Windows)

#### **Setup Instructions**

**Required Repository Secrets**:
1. **`GALLERY_API_TOKEN`**: PowerShell Gallery API key
   - Go to https://www.powershellgallery.com/account/apikeys
   - Create key with scope: `PSSEPCloud*` and "Push" permissions
   - Add to GitHub: Settings → Secrets and variables → Actions → New repository secret

2. **`GITHUB_TOKEN`**: Automatically provided by GitHub

**Configuration Files**:
- `build.yaml`: Pester configuration with test paths (`tests/Unit`, `tests/QA`)
- `GitVersion.yml`: Semantic versioning configuration
- Test execution uses CodeCoverageThreshold 0 for CI (adjustable)

#### **Current Status & Known Issues**

**✅ Working Correctly**:
- Build process and module packaging
- PowerShell version switching (5.1 vs 7.x)
- Test execution (19 tests pass on both versions)
- GitVersion semantic versioning
- Artifact management and deployment pipeline

**🔧 Known Issues to Fix**:
1. **NUnit XML Output**: Test results not properly exported for GitHub Actions consumption
2. **PSScriptAnalyzer Violations**:
   - Missing `[CmdletBinding(SupportsShouldProcess)]` for state-changing functions
   - Empty catch blocks in `New-UserAgentString.ps1:41,74`
   - Deprecated WMI cmdlet usage (use CIM instead)
   - Plural noun violations in cmdlet names
3. **DevSkim Security Scan**: Disabled on Windows (Linux container issue)

**Next Steps**:
1. Fix Pester NUnit XML export configuration
2. Resolve PSScriptAnalyzer code quality issues
3. Merge PR once tests report correctly

### Testing
- Uses Pester for unit testing with 85% code coverage requirement
- Unit tests mirror the source structure in `/tests/Unit/`
- Quality assurance tests in `/tests/QA/`
- Multi-platform testing (Windows PS 5.1/7, Linux, macOS)
- Any test errors should be documented in the `TESTS-RESULTS.md` file

## Architecture

### Module Structure (Sampler Framework)
- **`/source/`** - Main module source code
  - **`/Public/`** - 42+ exported cmdlets organized by functionality
  - **`/Private/`** - 18+ internal helper functions for API operations
  - **`/Classes/`** - PowerShell class definitions
  - **`PSSEPCloud.psd1`** - Module manifest
  - **`PSSEPCloud.Types.ps1xml`** - Custom type definitions

### Function Categories
1. **Authentication**: `Connect-SEPCloud`, `Get-SEPCloudToken`, `Clear-SEPCloudAuthentication`
2. **Device Management**: `Get-SEPCloudDevice`, `Move-SEPCloudDevice`, `Get-SEPCloudDeviceDetails`
3. **Policy Management**: `Get-SEPCloudPolicyDetails`, `Set-SEPCloudPolicy`, `Remove-SEPCloudPolicy`
4. **Security Operations**: `Start-SEPCloudFullScan`, `Block-SEPCloudFile`, `Start-SEPCloudDefinitionUpdate`
5. **Threat Intelligence**: `Get-SEPCloudThreatIntel*` functions for files, networks, CVEs
6. **Incident Management**: `Get-SEPCloudIncidents`, `Get-SEPCloudIncidentDetails`

### Architecture Pattern
- **Private functions** handle core API operations, authentication, and request building
- **Public functions** expose user-facing cmdlets with parameter validation
- **Script-scoped variables** manage connection state and regional configuration
- **Classes** define custom objects for structured data

## Authentication & Regional Support

The module uses OAuth2 authentication with region-specific endpoints:
- Europe: `api.sep.eu.securitycloud.symantec.com`
- North America: `api.sep.securitycloud.symantec.com`
- India: `api.sep.in.securitycloud.symantec.com`

Configure regions using `Set-SEPCloudRegion` before connecting.

## Code Standards

- All public functions require comprehensive help documentation
- Unit tests required for all functions (mirrors source structure)
- PSScriptAnalyzer compliance required
- 85% code coverage threshold
- Multi-platform compatibility (Windows, Linux, macOS)

## CI/CD Pipeline

<!-- Uses Azure DevOps pipeline (`azure-pipelines.yml`) with: -->
no CI/CD pipeline currently setup. Ideally GitHub Action needs to be setup
- Multi-platform testing (Windows PS 5.1/7, Linux, macOS)
<!-- - Code coverage reporting via Codecov -->
- Semantic versioning via GitVersion
- Automated publishing to PowerShell Gallery

## Error Resolution

1. CI Failures
   - Fix order:
     1. Formatting
     2. Type errors
     3. Linting
   - Type errors:
     - Get full line context
     - Check Optional types
     - Add type narrowing
     - Verify function signatures

2. Common Issues
   - Line length:
     - Break strings with parentheses
     - Multi-line function calls
     - Split imports
   - Types:
     - Add None checks
     - Narrow string types
     - Match existing patterns

3. Best Practices
   - Check git status before commits
   - Run formatters before type checks
   - Keep changes minimal
   - Follow existing patterns
   - Document public APIs
   - Test thoroughly
