$ModulePath = "$PSScriptRoot/WindowsReleaseInformation"
$ManifestPath = Join-Path $ModulePath "WindowsReleaseInformation.psd1"
$RequiredModules = @("PowerHTML")

# Install required modules if not already available
foreach ($module in $RequiredModules) {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        Write-Host "Installing required module: $module"
        try {
            Install-Module -Name $module -Force -Scope CurrentUser -ErrorAction Stop
        } catch {
            Write-Error "Failed to install required module '$module': $_"
            exit 1
        }
    } else {
        Write-Host "Required module '$module' is already installed."
    }
}

# Validate the module manifest
Write-Host "Validating module manifest..."
try {
    Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop
} catch {
    Write-Error "Manifest validation failed: $_"
    exit 1
}

# Publish the module
Write-Host "Publishing module..."
try {
    Publish-Module -Path $ModulePath -NuGetApiKey $Env:APIKEY -ErrorAction Stop
    Write-Host "Module published successfully."
} catch {
    Write-Error "Publishing failed: $_"
    exit 1
}
``