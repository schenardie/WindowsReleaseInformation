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
    #>

  [cmdletbinding()]
  param
  (
    [Parameter(Mandatory = $True)][ValidateSet("11","10")]  $OS,
    [Parameter(Mandatory = $False)] $Build,
    [Parameter(Mandatory = $False)] $KB,
    [Parameter(Mandatory = $False)] $ServicingOption,
    [Parameter(Mandatory = $False)] $Version
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
        foreach ($tablerow in ($table.Elements('tr') | Select-Object -Skip 1)) {

          $cells = @($tableRow.Elements('td')).InnerText
          if ($cells[0] -like "*&bull;*") { $cells[0] = $cells[0] -replace "  &bull;  ", " - " }
          $obj = New-Object -TypeName PSObject
          $obj | Add-Member -MemberType NoteProperty -Name "Operating System" -Value "Windows $os"
          $obj | Add-Member -MemberType NoteProperty -Name "Version" -Value $ver
          $obj | Add-Member -MemberType NoteProperty -Name "Servicing option" -Value $cells[0]
          $obj | Add-Member -MemberType NoteProperty -Name "Availability date" -Value $cells[1]
          $obj | Add-Member -MemberType NoteProperty -Name "OS build" -Value $cells[2]
          $obj | Add-Member -MemberType NoteProperty -Name "KB article" -Value $cells[3]
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

      if ($Build) { Return $data2 | Where-Object { $_."Os Build" -like "*$Build*" } | ConvertTo-Json }
      if ($KB) { Return $data2 | Where-Object { $_."KB article" -like "*$KB*" } | ConvertTo-Json }
      if ($ServicingOption) { Return $data2 | Where-Object { $_."Servicing option" -like "*$ServicingOption*" } | ConvertTo-Json }
      if ($Version) { Return $data2 | Where-Object { $_."Version" -like "*$Version*" } | ConvertTo-Json }
      else { Return $data2 | ConvertTo-Json } 

    }
    "11" {
      $url = 'https://docs.microsoft.com/en-us/windows/release-health/windows11-release-information'
      $WebResponse = Invoke-WebRequest $url
      $req = ConvertFrom-Html -Content $WebResponse

      $tables = $req.SelectNodes('//table') | Select-Object -skip 1

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
        foreach ($tablerow in ($table.Elements('tr') | Select-Object -Skip 1)) {

          $cells = @($tableRow.Elements('td')).InnerText
          if ($cells[0] -like "*&bull;*") { $cells[0] = $cells[0] -replace "  &bull;  ", " - " }
          $obj = New-Object -TypeName PSObject
          $obj | Add-Member -MemberType NoteProperty -Name "Operating System" -Value "Windows $os"
          $obj | Add-Member -MemberType NoteProperty -Name "Version" -Value $ver
          $obj | Add-Member -MemberType NoteProperty -Name "Servicing option" -Value $cells[0]
          $obj | Add-Member -MemberType NoteProperty -Name "Availability date" -Value $cells[1]
          $obj | Add-Member -MemberType NoteProperty -Name "OS build" -Value $cells[2]
          $obj | Add-Member -MemberType NoteProperty -Name "KB article" -Value $cells[3]
          $obj | Add-Member -MemberType NoteProperty -Name "End of Servicing" -Value $EOS
          $data += $obj  
        }
        $data2 += $data
      }

      if ($Build) { Return $data2 | Where-Object { $_."Os Build" -like "*$Build*" } | ConvertTo-Json }
      if ($KB) { Return $data2 | Where-Object { $_."KB article" -like "*$KB*" } | ConvertTo-Json }
      if ($ServicingOption) { Return $data2 | Where-Object { $_."Servicing option" -like "*$ServicingOption*" } | ConvertTo-Json }
      if ($Version) { Return $data2 | Where-Object { $_."Version" -like "*$Version*" } | ConvertTo-Json }
      else { Return $data2 | ConvertTo-Json } 

    }
    default { "Could not find information for the operating system specified."; break }

  }
}