# WindowsReleaseInformation
PowerShell module to Parse Windows release information from the Microsoft official release information page

## Installation
Install-Module WindowsReleaseInformation

# Function Get-WinReleaseCurrent

 **.Synopsis**

    Parse information from Windows Release Information for current channels

**.Description**

    This cmdlet parses data form windows release information about current versions and output to a json object.

**.EXAMPLE**

    Return info on all versions on servicing channel for Windows 10
    Get-WinReleaseCurrent -OS 10 -Channel servicing
    
**.EXAMPLE**

    Return info on version 22H2 on servicing channel for Windows 11
    Get-WinReleaseCurrent -OS 11 -Channel servicing -Version 22H2

**.EXAMPLE**

    Return info on version 1507 on ltsb channel for Windows 10
    Get-WinReleaseCurrent -OS 10 -Channel ltsb -Version 1507

# Function Get-WinReleaseHistory

**.Synopsis**

      Parse information from Windows Release Information history

**.Description**
      
      This cmdlet parses data form windows release information about historic versions and output to a json object.

**.EXAMPLE**
    Return info on all builds for Windows 11 Version 21H2
    Get-WinReleaseHistory -OS 11 -Version 21H2

**.EXAMPLE**

    Return info on Windows 11 for KB 5006674
    Get-WinReleaseHistory -OS 11 -KB KB5006674

**.EXAMPLE**

    Return info on all builds for Windows 10 Version 21H2 and 21H2
    Get-WinReleaseHistory -OS 10 -Version 21H

**.EXAMPLE**

    Return info on Windows 10 for KB 5020030
    Get-WinReleaseHistory -OS 10 -KB KB5020030