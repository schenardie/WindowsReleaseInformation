Function Get-WinReleaseCurrent {
  <#
     .Synopsis
      Parse information from Windows Release Information current
    
     .Description
      This cmdlet parses data form windows release information about current versions and output to a json object.
     .EXAMPLE
      The function can be run without parameters
    #>

  [cmdletbinding()]
  param
  (
    [Parameter(Mandatory = $True)]  $OS,
    [Parameter(Mandatory = $False)] $Build,
    [Parameter(Mandatory = $False)] $KB,
    [Parameter(Mandatory = $False)] $ServiceOption,
    [Parameter(Mandatory = $False)] $Version
  )

  Switch ($os) {
    "10" {
      $url = 'https://docs.microsoft.com/en-us/windows/release-health/release-information'
      $WebResponse = Invoke-WebRequest $url
      $req = ConvertFrom-Html -Content $WebResponse

      $tables = $req.SelectNodes('//table') | Select-Object -First 2

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
          $obj | Add-Member -MemberType NoteProperty -Name "Kb article" -Value $cells[3]
          $obj | Add-Member -MemberType NoteProperty -Name "End of Servicing" -Value $EOS
          $data += $obj  
        }
        $data2 += $data
      }
      
      if ($Build) { Return $data2 | Where-Object { $_."Os Build" -like "*$Build*" } | ConvertTo-Json }
      if ($KB) { Return $data2 | Where-Object { $_."Kb article" -like "*$KB*" } | ConvertTo-Json }
      if ($ServiceOption) { Return $data2 | Where-Object { $_."Servicing option" -like "*$ServiceOption*" } | ConvertTo-Json }
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
          $obj | Add-Member -MemberType NoteProperty -Name "Kb article" -Value $cells[3]
          $obj | Add-Member -MemberType NoteProperty -Name "End of Servicing" -Value $EOS
          $data += $obj  
        }
        $data2 += $data
      }

      if ($Build) { Return $data2 | Where-Object { $_."Os Build" -like "*$Build*" } | ConvertTo-Json }
      if ($KB) { Return $data2 | Where-Object { $_."Kb article" -like "*$KB*" } | ConvertTo-Json }
      if ($ServiceOption) { Return $data2 | Where-Object { $_."Servicing option" -like "*$ServiceOption*" } | ConvertTo-Json }
      if ($Version) { Return $data2 | Where-Object { $_."Version" -like "*$Version*" } | ConvertTo-Json }
      else { Return $data2 | ConvertTo-Json } 

    }

  }
}





Function Get-WinReleaseChannel {
  [cmdletbinding()]
  param
  (
      [Parameter(Mandatory = $true)]$channel
  )


  $url = "https://docs.microsoft.com/en-us/windows/release-health/release-information"
  $WebResponse = Invoke-WebRequest $url
  $req = ConvertFrom-Html -Content $WebResponse


  switch ($channel) {
      "Semi-Annual" { $tables = $req.SelectNodes('//table') | Select-Object -first 1; break }
      "LTSB" { $tables = $req.SelectNodes('//table') | Select-Object -skip 1 | Select-Object -first 1; break }
      default { "Not a valid channel"; break }
  }

  $data2 = @()
  foreach ($table in $tables) {
      $data = @()
      foreach ($tablerow in ($tables.Elements('tr') | Select-Object -Skip 1)) {

          $cells = @($tableRow.Elements('td')).InnerText
          $obj = New-Object -TypeName PSObject
          $obj | Add-Member -MemberType NoteProperty -Name "Version" -Value $cells[0]
          $obj | Add-Member -MemberType NoteProperty -Name "Servicing option" -Value $cells[1]
          $obj | Add-Member -MemberType NoteProperty -Name "Availability date" -Value $cells[2]
          $obj | Add-Member -MemberType NoteProperty -Name "Latest revision date" -Value $cells[3]
          $obj | Add-Member -MemberType NoteProperty -Name "OS build" -Value $cells[4]
          $obj | Add-Member -MemberType NoteProperty -Name "End of service: Home, Pro, Pro Education and Pro for Workstations" -Value $cells[5]
          $obj | Add-Member -MemberType NoteProperty -Name "End of service: Enterprise, Education and IoT Enterprise" -Value $cells[6]
          $obj | Add-Member -MemberType NoteProperty -Name "Operating System" -Value "Win 10" -Force
          $obj.Version = $obj.Version -replace " \(.*?\)", ""
          $data += $obj
      }
      $data2 += $data
  }
  return $data2

}