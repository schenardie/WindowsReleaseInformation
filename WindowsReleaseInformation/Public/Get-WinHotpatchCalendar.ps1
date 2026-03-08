Function Get-WinHotpatchCalendar {
  <#
     .Synopsis
      Parse the Windows 11 hotpatch calendar from Windows Release Information
     .Description
      This cmdlet parses the Windows 11 hotpatch calendar section and returns
      scheduled and released hotpatch and baseline updates as a JSON object.
      Hotpatch updates are delivered without a restart; baseline updates (every
      quarter) require a restart.
     .Parameter Version
      (Optional - Any valid Version e.g. 24H2, 25H2)
      Filter results to a specific Windows 11 version.
     .Parameter Year
      (Optional - Any valid calendar year e.g. 2025, 2026)
      Filter results to a specific calendar year.
     .Parameter Month
      (Optional - Any valid month name e.g. January, February)
      Filter results to a specific month.
     .Parameter Type
      (Optional - Hotpatch / Baseline)
      Filter results to a specific update type.
     .EXAMPLE
     #Return all hotpatch calendar entries
      Get-WinHotpatchCalendar
     .EXAMPLE
     #Return hotpatch calendar for Windows 11 version 24H2
      Get-WinHotpatchCalendar -Version 24H2
     .EXAMPLE
     #Return only Hotpatch (no-restart) entries for 2026
      Get-WinHotpatchCalendar -Year 2026 -Type Hotpatch
     .EXAMPLE
     #Return all entries for January across all versions and years
      Get-WinHotpatchCalendar -Month January
    #>

  [cmdletbinding()]
  param
  (
    [Parameter(Mandatory = $False)] $Version,
    [Parameter(Mandatory = $False)] $Year,
    [Parameter(Mandatory = $False)] $Month,
    [Parameter(Mandatory = $False)] $Type
  )

  $url = 'https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information'
  $WebResponse = Invoke-WebRequest $url -UseBasicParsing
  $req = ConvertFrom-Html -Content $WebResponse

  # Select only tables that appear after the hotpatch calendar heading
  $tables = $req.SelectNodes('//h2[contains(translate(., "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "abcdefghijklmnopqrstuvwxyz"), "hotpatch calendar")]/following::table')

  if (-not $tables) {
    "Could not find the Windows 11 hotpatch calendar section on the page."
    return
  }

  $data2 = @()
  $lastFoundVersion = ""
  $lastFoundYear = ""

  foreach ($table in $tables) {
    $ver = "Unknown"
    $calYear = "Unknown"

    # Walk backwards through preceding siblings to find the nearest version and calendar year headings.
    # Anchor the version regex (^) to avoid matching version references inside note paragraphs.
    # "Calendar year" is distinctive enough not to require anchoring.
    $precedingSiblings = $table.SelectNodes('preceding-sibling::*')
    if ($precedingSiblings) {
      for ($j = $precedingSiblings.Count - 1; $j -ge 0; $j--) {
        $siblingText = $precedingSiblings[$j].InnerText.Trim()

        if ($calYear -eq "Unknown" -and $siblingText -match "Calendar\s+year\s+(\d{4})") {
          $calYear = $matches[1]
        }
        if ($ver -eq "Unknown" -and $siblingText -match "^Version\s+(\d{2}H\d)") {
          $ver = $matches[1]
        }

        # Stop once both are found
        if ($ver -ne "Unknown" -and $calYear -ne "Unknown") { break }
      }
    }

    # Fall back to the last successfully detected values for continuation tables
    if ($ver -eq "Unknown" -and $lastFoundVersion) { $ver = $lastFoundVersion }
    if ($calYear -eq "Unknown" -and $lastFoundYear) { $calYear = $lastFoundYear }

    if ($ver -ne "Unknown") { $lastFoundVersion = $ver }
    if ($calYear -ne "Unknown") { $lastFoundYear = $calYear }

    foreach ($tablerow in ($table.SelectNodes('.//tr') | Select-Object -Skip 1)) {
      $cells = @($tableRow.SelectNodes('.//td')).InnerText

      $obj = New-Object -TypeName PSObject
      $obj | Add-Member -MemberType NoteProperty -Name "Operating System" -Value "Windows 11"
      $obj | Add-Member -MemberType NoteProperty -Name "Version"          -Value $ver
      $obj | Add-Member -MemberType NoteProperty -Name "Calendar Year"    -Value $calYear
      $obj | Add-Member -MemberType NoteProperty -Name "Month"            -Value $cells[0]
      $obj | Add-Member -MemberType NoteProperty -Name "Update type"      -Value $cells[1]
      $obj | Add-Member -MemberType NoteProperty -Name "Type"             -Value $cells[2]
      $obj | Add-Member -MemberType NoteProperty -Name "Availability date"-Value $cells[3]
      $obj | Add-Member -MemberType NoteProperty -Name "OS build"         -Value $cells[4]
      $obj | Add-Member -MemberType NoteProperty -Name "KB article"       -Value $cells[5]
      $data2 += $obj
    }
  }

  if ($Version) { $data2 = $data2 | Where-Object { $_."Version"       -like "*$Version*" } }
  if ($Year)    { $data2 = $data2 | Where-Object { $_."Calendar Year"  -like "*$Year*"    } }
  if ($Month)   { $data2 = $data2 | Where-Object { $_."Month"          -like "*$Month*"   } }
  if ($Type)    { $data2 = $data2 | Where-Object { $_."Type"           -like "*$Type*"    } }

  if (-not $data2) {
    "Could not find hotpatch calendar entries matching the specified filters."
    return
  }

  Return $data2 | ConvertTo-Json
}
