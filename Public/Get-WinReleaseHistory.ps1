Function Get-WinReleaseHistory {
  <#
     .Synopsis
      Parse information from Windows Release Information history
     .Description
      This cmdlet parses data form windows release information about historic versions and output to a json object.
     .Parameter OS
      (Mandatory - 10/11)
      Specify desired operating system.
     .Parameter Build
      (Optional - Any valid build number)
      Specify a specific or partial build to return information on
     .Parameter KB
      (Optional - Any valid KB)
      Specify a specific or partial KB to return information on
     .Parameter ServicingOption
      (Optional - Any valid Servicing Option)
      Specify a specific or partial Servicing Option to return information on
     .Parameter Version
      (Optional - Any valid Version)
      Specify a specific or partial Version to return information on
     .Parameter Type
      (Optional - Any valid Type)
      Specify a specific or partial Type to return information on (applies to hotpatch builds)
     .EXAMPLE
     #Return info on all builds for Windows 11 Version 21H2
      Get-WinReleaseHistory -OS 11 -Version 21H2
     .EXAMPLE
     #Return info on Windows 11 for KB 5006674
      Get-WinReleaseHistory -OS 11 -KB KB5006674
     .EXAMPLE
     #Return info on all builds for Windows 10 Version 21H2 and 21H2
      Get-WinReleaseHistory -OS 10 -Version 21H
     .EXAMPLE
     #Return info on Windows 10 for KB 5020030
      Get-WinReleaseHistory -OS 10 -KB KB5020030
     .EXAMPLE
     #Return info on Windows 11 hotpatch builds only
      Get-WinReleaseHistory -OS 11 -Type Hotpatch
    #>

  [cmdletbinding()]
  param
  (
    [Parameter(Mandatory = $True)][ValidateSet("11","10")]  $OS,
    [Parameter(Mandatory = $False)] $Build,
    [Parameter(Mandatory = $False)] $KB,
    [Parameter(Mandatory = $False)] $ServicingOption,
    [Parameter(Mandatory = $False)] $Version,
    [Parameter(Mandatory = $False)] $Type
  )

  Switch ($os) {
    "10" {
      $url = 'https://docs.microsoft.com/en-us/windows/release-health/release-information'
      $WebResponse = Invoke-WebRequest $url
      $req = ConvertFrom-Html -Content $WebResponse

      $tables = $req.SelectNodes('//table') | Select-Object -skip 2

      $data2 = @()
      foreach ($table in $tables) {
        if ($table.ParentNode.SelectNodes('strong').InnerText)
        { $ver = ($table.ParentNode.SelectNodes('strong').InnerText).Split(' ')[1] }
        else {
          $Ver = ($table.ParentNode.FirstChild.InnerText).Split(' ')[1]
        }
        if ($ver -like "*End of servicing*") { $EOS = $true }
        else { $EOS = $False }
        $data = @()
        foreach ($tablerow in ($table.SelectNodes('.//tr') | Select-Object -Skip 1)) {

          $cells = @($tableRow.SelectNodes('.//td')).InnerText
          if ($cells[0] -like "*&bull;*") { $cells[0] = $cells[0] -replace "  &bull;  ", " - " }
          # Replace problematic Unicode characters with forward slashes and clean up extra spaces
          if ($cells[0] -like "* ??? *") { $cells[0] = $cells[0] -replace "\s*\?\?\?\s*", " / " -replace "\s+", " " }
          $obj = New-Object -TypeName PSObject
          $obj | Add-Member -MemberType NoteProperty -Name "Operating System" -Value "Windows $os"
          # Clean version by removing parenthetical content and superscript footnote references
          $cleanedVersion = $ver -replace " \(.*?\)", "" -replace "(?<=\d[A-Z]\d)\d+$", ""
          $obj | Add-Member -MemberType NoteProperty -Name "Version" -Value $cleanedVersion
          $obj | Add-Member -MemberType NoteProperty -Name "Servicing option" -Value $cells[0]
          $obj | Add-Member -MemberType NoteProperty -Name "Update type" -Value $cells[1]
          $obj | Add-Member -MemberType NoteProperty -Name "Availability date" -Value $cells[2]
          $obj | Add-Member -MemberType NoteProperty -Name "OS build" -Value $cells[3]
          $obj | Add-Member -MemberType NoteProperty -Name "KB article" -Value $cells[4]
          $obj | Add-Member -MemberType NoteProperty -Name "End of Servicing" -Value $EOS
          $data += $obj  
        }
        $data2 += $data
      }
      if ($Version) {
        $filteredData = $data2 | Where-Object { $_."Version" -like "*$Version*"  }
        if ($filteredData) {
          # Convert the filtered data to JSON format and return it
          $filteredData | ConvertTo-Json
        } else {
          # Return a message if no matching builds were found
          "Could not find information for the version specified."; break
        }
      }

      if ($Build) { Return $data2 | Where-Object { $_."OS build" -like "*$Build*" } | ConvertTo-Json }
      if ($KB) { Return $data2 | Where-Object { $_."KB article" -like "*$KB*" } | ConvertTo-Json }
      if ($ServicingOption) { Return $data2 | Where-Object { $_."Servicing option" -like "*$ServicingOption*" } | ConvertTo-Json }
      if ($Type) { Return $data2 | Where-Object { $_."Type" -like "*$Type*" } | ConvertTo-Json }
      if (!$Version) { Return $data2 | ConvertTo-Json } 

    }
    "11" {
      $url = 'https://docs.microsoft.com/en-us/windows/release-health/windows11-release-information'
      $WebResponse = Invoke-WebRequest $url
      $req = ConvertFrom-Html -Content $WebResponse

      $tables = $req.SelectNodes('//table') | Select-Object -skip 2

      $data2 = @()
      $lastFoundVersion = ""
      foreach ($table in $tables) {
        # Check if this is a hotpatch table by examining the headers
        $headerRow = $table.SelectNodes('.//tr') | Select-Object -First 1
        $headerCells = $headerRow.SelectNodes('.//th')
        $isHotpatchTable = $headerCells.InnerText -contains "Type"
        
        # Look for version in strong elements
        $ver = "Unknown"
        $strongElements = $table.ParentNode.SelectNodes('strong')
        if ($strongElements) {
          foreach ($strong in $strongElements) {
            $strongText = $strong.InnerText.Trim()
            if ($strongText -match "Version\s+(\d{2}H\d)") {
              $ver = $matches[1]
              $lastFoundVersion = $ver
              break
            }
          }
        }
        
        # If no version found in strong elements, try alternative methods
        if ($ver -eq "Unknown") {
          $strongText = $strongElements.InnerText
          if ($strongText -and $strongText.Split(' ').Count -ge 2 -and $strongText -notmatch "Calendar|year") {
            # Use old logic for non-hotpatch tables (but avoid "Calendar year" patterns)
            $ver = $strongText.Split(' ')[1]
            $lastFoundVersion = $ver
          }
        }
        
        # If still no version found, try other methods
        if ($ver -eq "Unknown") {
          # For hotpatch tables, find the most recent "Version X" in preceding siblings
          $precedingSiblings = $table.SelectNodes('preceding-sibling::*')
          if ($precedingSiblings) {
            # Walk backwards through preceding elements to find version
            for ($j = $precedingSiblings.Count - 1; $j -ge 0; $j--) {
              $siblingText = $precedingSiblings[$j].InnerText
              if ($siblingText -match "Version\s+(\d{2}H\d)") {
                $ver = $matches[1]
                $lastFoundVersion = $ver
                break
              }
            }
          }
          # If still not found, use the last found version (for continuation tables)
          if ($ver -eq "Unknown" -and $lastFoundVersion) {
            $ver = $lastFoundVersion
          }
          # If still not found, try the old fallback method
          if ($ver -eq "Unknown" -and $table.ParentNode.FirstChild.InnerText) {
            $Ver = ($table.ParentNode.FirstChild.InnerText).Split(' ')[1]
          }
        }
        if ($ver -like "*End of servicing*") { $EOS = $true }
        else { $EOS = $False }
        $data = @()
        foreach ($tablerow in ($table.SelectNodes('.//tr') | Select-Object -Skip 1)) {

          $cells = @($tableRow.SelectNodes('.//td')).InnerText
          if ($cells[0] -like "*&bull;*") { $cells[0] = $cells[0] -replace "  &bull;  ", " - " }
          # Replace problematic Unicode characters with forward slashes and clean up extra spaces
          if ($cells[0] -like "* ??? *") { $cells[0] = $cells[0] -replace "\s*\?\?\?\s*", " / " -replace "\s+", " " }
          $obj = New-Object -TypeName PSObject
          $obj | Add-Member -MemberType NoteProperty -Name "Operating System" -Value "Windows $os"
          # Clean version by removing parenthetical content and superscript footnote references
          $cleanedVersion = $ver -replace " \(.*?\)", "" -replace "(?<=\d[A-Z]\d)\d+$", ""
          $obj | Add-Member -MemberType NoteProperty -Name "Version" -Value $cleanedVersion
          
          if ($isHotpatchTable) {
            # Hotpatch table format: Month, Update type, Type, Availability date, Build, KB article
            $obj | Add-Member -MemberType NoteProperty -Name "Month" -Value $cells[0]
            $obj | Add-Member -MemberType NoteProperty -Name "Update type" -Value $cells[1]
            $obj | Add-Member -MemberType NoteProperty -Name "Type" -Value $cells[2]
            $obj | Add-Member -MemberType NoteProperty -Name "Availability date" -Value $cells[3]
            $obj | Add-Member -MemberType NoteProperty -Name "OS build" -Value $cells[4]
            $obj | Add-Member -MemberType NoteProperty -Name "KB article" -Value $cells[5]
          } else {
            # Standard table format: Servicing option, Update type, Availability date, Build, KB article
            $obj | Add-Member -MemberType NoteProperty -Name "Servicing option" -Value $cells[0]
            $obj | Add-Member -MemberType NoteProperty -Name "Update type" -Value $cells[1]
            $obj | Add-Member -MemberType NoteProperty -Name "Availability date" -Value $cells[2]
            $obj | Add-Member -MemberType NoteProperty -Name "OS build" -Value $cells[3]
            $obj | Add-Member -MemberType NoteProperty -Name "KB article" -Value $cells[4]
          }
          
          $obj | Add-Member -MemberType NoteProperty -Name "End of Servicing" -Value $EOS
          $data += $obj  
        }
        $data2 += $data
      }

      # Filter out hotpatch and baseline entries unless specifically requested via Type parameter
      if (-not $Type) { $data2 = $data2 | Where-Object { $_."Type" -notlike "*Hotpatch*" -and $_."Type" -notlike "*Baseline*" } }
      
      if ($Build) { Return $data2 | Where-Object { $_."OS build" -like "*$Build*" } | ConvertTo-Json }
      if ($KB) { Return $data2 | Where-Object { $_."KB article" -like "*$KB*" } | ConvertTo-Json }
      if ($ServicingOption) { Return $data2 | Where-Object { $_."Servicing option" -like "*$ServicingOption*" } | ConvertTo-Json }
      if ($Type) { 
        if ($Type -like "*Hotpatch*") {
          # When requesting hotpatch, show both hotpatch and baseline entries from hotpatch tables
          Return $data2 | Where-Object { $_."Type" -like "*Hotpatch*" -or $_."Type" -like "*Baseline*" } | ConvertTo-Json
        } else {
          Return $data2 | Where-Object { $_."Type" -like "*$Type*" } | ConvertTo-Json
        }
      }
      if ($Version) { 
        $filteredData = $data2 | Where-Object { $_."Version" -like "*$Version*" }
        Return $filteredData | ConvertTo-Json 
      }
      else { Return $data2 | ConvertTo-Json } 

    }
    default { "Could not find information for the operating system specified."; break }

  }
}