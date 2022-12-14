Function Get-WinReleaseCurrent {
  <#
     .Synopsis
      Parse information from Windows Release Information for current channels
     .Description
      This cmdlet parses data form windows release information about current versions and output to a json object.
     .Parameter OS
      (Mandatory - 10/11)
      Specify desired operating system.
     .Parameter Channel
      (Mandatory - Servicing/LTSB/LTSC)
      Specify a specific or partial build to return information on. LTSB and LTSC can be used interchangeably 
     .Parameter Version
      (Optional - Any valid Version)
      Specify a specific or partial Version to return information on
     .EXAMPLE
     #Return info on all versions on servicing channel for Windows 10
      Get-WinReleaseCurrent -OS 10 -Channel servicing
     .EXAMPLE
     #Return info on version 22H2 on servicing channel for Windows 11
       Get-WinReleaseCurrent -OS 11 -Channel servicing -Version 22H2
     .EXAMPLE
      #Return info on version 1507 on ltsb channel for Windows 10
       Get-WinReleaseCurrent -OS 10 -Channel ltsb -Version 1507
    #>
  #>

  [cmdletbinding()]
  param
  (
    [Parameter(Mandatory = $True)][ValidateSet("11", "10")]  $OS,
    [Parameter(Mandatory = $True)][ValidateSet("Servicing", "LTSB", "LTSC")]  $Channel,
    [Parameter(Mandatory = $False)] $Version
  )

  Switch ($os) {
    "10" {
      $url = "https://docs.microsoft.com/en-us/windows/release-health/release-information"
      $WebResponse = Invoke-WebRequest $url
      $req = ConvertFrom-Html -Content $WebResponse
    
    
      switch ($channel) {
        { "servicing" -eq $_ } { $tables = $req.SelectNodes('//table') | Select-Object -first 1; break }
        { 'LTSB', 'LTSC' -eq $_ } { $tables = $req.SelectNodes('//table') | Select-Object -skip 1 | Select-Object -first 1; break }
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
          $obj | Add-Member -MemberType NoteProperty -Name "Operating System" -Value "Win 11" -Force
          $obj.Version = $obj.Version -replace " \(.*?\)", ""
          $data += $obj
        }
        $data2 += $data
      }
      if ($Version) { Return $data2 | Where-Object { $_."Version" -like "*$Version*" } | ConvertTo-Json }
      else { Return $data2 | ConvertTo-Json } 
    }
    "11" {
      $url = "https://docs.microsoft.com/en-us/windows/release-health/windows11-release-information"
      $WebResponse = Invoke-WebRequest $url
      $req = ConvertFrom-Html -Content $WebResponse
  
  
      switch ($channel) {
        { "servicing" -eq $_ } { $tables = $req.SelectNodes('//table') | Select-Object -first 1; break }
        { 'LTSB', 'LTSC' -eq $_ } { 'No LTSB / LTSC channel release for Windows 11 exists.' ; break }
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
          $obj | Add-Member -MemberType NoteProperty -Name "Operating System" -Value "Win 11" -Force
          $obj.Version = $obj.Version -replace " \(.*?\)", ""
          $data += $obj
        }
        $data2 += $data
      }
      if ($Version) { Return $data2 | Where-Object { $_."Version" -like "*$Version*" } | ConvertTo-Json }
      else { Return $data2 | ConvertTo-Json } 

    }
    default { "Could not find information for the operating system specified."; break }
  }
}
