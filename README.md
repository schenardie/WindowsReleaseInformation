# WindowsReleaseInformation
PowerShell module to parse Windows release information from the Microsoft official release information page.

## Installation

```powershell
Install-Module WindowsReleaseInformation
```

---

## Functions

- [Get-WinReleaseCurrent](#function-get-winreleasecurrent)
- [Get-WinReleaseHistory](#function-get-winreleasehistory)
- [Get-WinHotpatchCalendar](#function-get-winhotpatchcalendar)

---

# Function Get-WinReleaseCurrent

**.Synopsis**

    Parse information from Windows Release Information for current channels

**.Description**

    This cmdlet parses data from Windows release information about current versions and outputs a JSON object.

**.EXAMPLE**

    # Return info on all versions on servicing channel for Windows 10
    Get-WinReleaseCurrent -OS 10 -Channel servicing

**.EXAMPLE**

    # Return info on version 22H2 on servicing channel for Windows 11
    Get-WinReleaseCurrent -OS 11 -Channel servicing -Version 22H2

**.EXAMPLE**

    # Return info on version 1507 on ltsb channel for Windows 10
    Get-WinReleaseCurrent -OS 10 -Channel ltsb -Version 1507

---

# Function Get-WinReleaseHistory

**.Synopsis**

    Parse information from Windows Release Information history

**.Description**

    This cmdlet parses data from Windows release information about historic versions and outputs a JSON object.

**.EXAMPLE**

    # Return info on all builds for Windows 11 Version 23H2
    Get-WinReleaseHistory -OS 11 -Version 23H2

**.EXAMPLE**

    # Return info on Windows 11 for KB 5006674
    Get-WinReleaseHistory -OS 11 -KB KB5006674

**.EXAMPLE**

    # Return info on all builds for Windows 10 versions matching 21H
    Get-WinReleaseHistory -OS 10 -Version 21H

**.EXAMPLE**

    # Return info on Windows 10 for KB 5020030
    Get-WinReleaseHistory -OS 10 -KB KB5020030

**.EXAMPLE**

    # Return Windows 11 hotpatch and baseline builds only
    Get-WinReleaseHistory -OS 11 -Type Hotpatch

---

# Function Get-WinHotpatchCalendar

**.Synopsis**

    Parse the Windows 11 hotpatch calendar from Windows Release Information

**.Description**

    This cmdlet parses the Windows 11 hotpatch calendar section and returns scheduled and released
    hotpatch and baseline updates as a JSON object.

    With hotpatching, devices receive a **baseline** cumulative update (restart required) in the first
    month of each quarter. During the following two months, devices receive a **hotpatch** update
    containing only security fixes — with no restart required.

    Currently supported versions: **24H2**, **25H2**

**.Parameters**

| Parameter  | Mandatory | Description |
|------------|-----------|-------------|
| `-Version` | No | Filter by Windows 11 version (e.g. `24H2`, `25H2`) |
| `-Year`    | No | Filter by calendar year (e.g. `2025`, `2026`) |
| `-Month`   | No | Filter by month name (e.g. `January`, `February`) |
| `-Type`    | No | Filter by update type (`Hotpatch` or `Baseline`) |

**.EXAMPLE**

    # Return the full hotpatch calendar for all versions and years
    Get-WinHotpatchCalendar

**.EXAMPLE**

    # Return all hotpatch calendar entries for Windows 11 24H2
    Get-WinHotpatchCalendar -Version 24H2

**.EXAMPLE**

    # Return only no-restart hotpatch updates planned for 2026
    Get-WinHotpatchCalendar -Year 2026 -Type Hotpatch

**.EXAMPLE**

    # Return all baseline (restart-required) updates across all versions
    Get-WinHotpatchCalendar -Type Baseline

**.EXAMPLE**

    # See what is scheduled for January across all versions and years
    Get-WinHotpatchCalendar -Month January

**.EXAMPLE**

    # Return the 25H2 hotpatch calendar for 2025
    Get-WinHotpatchCalendar -Version 25H2 -Year 2025

---

## Changelog

### 1.2.1
- **Fix:** Added `-UseBasicParsing` to all `Invoke-WebRequest` calls for compatibility with environments where the Internet Explorer engine is unavailable (e.g. PowerShell Core, Windows Server Core, non-Windows systems).

### 1.2.0
- **New:** Added `Get-WinHotpatchCalendar` function to parse the Windows 11 hotpatch calendar section, returning scheduled and released Hotpatch and Baseline updates with Version, Calendar Year, Month, Type, Availability date, OS build, and KB article.
- **Fix:** Resolved a bug in `Get-WinReleaseHistory` where Windows 11 23H2 builds were incorrectly labelled as 22H2. A note paragraph in the 23H2 section referenced "version 22H2", which was being matched before the actual version heading.

### 1.1.2
- Added filtering to exclude hotpatch entries by default in `Get-WinReleaseHistory`.
- Added `-Type` parameter to `Get-WinReleaseHistory` to filter by `Baseline` or `Hotpatch` entries.

### 1.1.1
- Major revamp of `Get-WinReleaseHistory` to improve parsing and add Windows 11 support.

### 1.0.2
- Minor adjustments.

### 1.0.0
- Initial module creation.