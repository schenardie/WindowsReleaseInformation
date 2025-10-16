<#
 .Synopsis
Module used to query Windows release information for Windows 10 and 11

 .Description
 Will parse the tables Windows release information pages and return a json with the information requested.

 .NOTES
        Author:      Jose Schenardie
        Contact:     @schenardie
        Created:     13/12/2022
        Updated:     13/12/2022
        Version history:
        1.0.0 - (13/12/2022) Module creation
        1.0.2 - (20/12/2022) Minor adjustments
        1.1.1 - Major revamp of Get-WinReleaseHistory to improve parsing and add Windows 11 support
        1.1.2 - Added filtering to exclude hotpatch entries by default in Get-WinReleaseHistory and added Type parameter to allow filtering by Baseline or Hotpatch entries

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