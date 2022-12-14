<#
 .Synopsis
Module used to query Windows Release Information for Windows 10 and 11 (https://learn.microsoft.com/en-us/windows/release-health/release-information)

 .Description
 Will parse the tables Windows Release Information pages and return a json with the information requested.

 .Example
   # Get Release information for Windows 10 with build 22h2
   Get-WindowsReleaseInformation -OS windows10 -Version 22h2

 .NOTES
        Author:      Jose Schenardie
        Contact:     @schenardie
        Created:     13/12/2022
        Updated:     13/12/2022
        Version history:
        1.0.0 - (13/12/2022) Module Creation

#>
[CmdletBinding()]
Param()
Process {
    # Locate all the public and private function specific files
    $PublicFunctions = Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath "Public") -Filter "*.ps1" -ErrorAction SilentlyContinue

    # Dot source the function files
    foreach ($Function in $PublicFunctions) {
        try {
            . $Function.FullName -ErrorAction Stop
        }
        catch [System.Exception] {
            Write-Error -Message "Failed to import function '$($Function.FullName)' with error: $($_.Exception.Message)"
        }
    }

    Export-ModuleMember -Function $PublicFunctions.BaseName -Alias *
}