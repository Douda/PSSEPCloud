# This file is intentionally left empty. It is must be left here for the module
# manifest to refer to. It is recreated during the build process.

# Dot-source all private functions
Get-ChildItem -Path "$PSScriptRoot/Private/*.ps1" | ForEach-Object {
    . $_.FullName
}

# Dot-source all public functions
Get-ChildItem -Path "$PSScriptRoot/Public/*.ps1" | ForEach-Object {
    . $_.FullName
}