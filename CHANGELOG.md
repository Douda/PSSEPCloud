# Changelog for PSSEPCloud

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Set-SEPCloudRegion function to set the correct region for the SEPCloud API
- Update-AllowListPolicyByFileName function to add a filename to the allow list policy
- Update-AllowListPolicyByFileHash function to add a file hash to the allow list policy


### Changed

- For changes in existing functionality.

### Deprecated

- For soon-to-be removed features.

### Removed

- For now removed features.

### Fixed

- fixed nested body structure from Get-SEPCloudAPIData with new helper function New-NestedBodyString

### Security

- In case of vulnerabilities.
