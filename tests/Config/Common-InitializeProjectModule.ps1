function Initialize-ProjectModule {
    param ()

    $ProjectPath = "$PSScriptRoot/../.." | Convert-Path
    $ProjectName = (Get-ChildItem $ProjectPath/*/*.psd1 | Where-Object {
    ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
            $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false }) }
    ).BaseName

    Remove-Module -Name $ProjectName -Force -ErrorAction SilentlyContinue

    # Force module rebuild for dev purposes
    # TODO remove this part or comment when publishing
    Remove-Item -Path "$PSScriptRoot/../../Output/$ProjectName" -Recurse -Force -ErrorAction SilentlyContinue

    if (-not (Test-Path "$ProjectPath/Output/$ProjectName/$ProjectName.psd1")) {
        if (-not (Get-Module -ListAvailable -Name "ModuleBuilder")) {
            Install-Module -Name ModuleBuilder -Scope CurrentUser
        }
        Build-Module -SourcePath "$ProjectPath/Source/$ProjectName.psd1"
    }
    Import-Module "$ProjectPath/Output/$ProjectName/$ProjectName.psm1" -Force

}

Initialize-ProjectModule
