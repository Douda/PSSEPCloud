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

The project uses GitHub Actions for continuous integration and deployment:

- **Main CI/CD Pipeline** (`.github/workflows/ci-cd.yml`):
  - Triggers on pushes to `main` branch and version tags
  - Tests on Windows with PowerShell 5.1 and PowerShell 7.x
  - Automatic deployment to PowerShell Gallery on successful tests
  - Requires `GALLERY_API_TOKEN` secret for PowerShell Gallery publishing

- **Pull Request Validation** (`.github/workflows/pr.yml`):
  - Runs on all pull requests to `main` branch
  - Performs code quality checks, security scans, and tests
  - Validates help documentation completeness
  - Runs PSScriptAnalyzer with PSGallery settings

#### Required Repository Secrets
- `GALLERY_API_TOKEN`: PowerShell Gallery API key for module publishing
- `GITHUB_TOKEN`: Automatically provided by GitHub for releases and PR creation

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
