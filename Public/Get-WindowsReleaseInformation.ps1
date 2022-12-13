Function Get-WindowsReleaseInformation {
    <#
     .Synopsis
      Parse information from Microsoft Windows Release Information Pages
    
     .Description
      This cmdlet parses data form windows release information page and output to a json file.
    
     .Parameter OS

     .Example
    
    #>

    [cmdletbinding()]
    param
    (
      [Parameter(Mandatory = $true, HelpMessage = "Select the Windows build you want information on")][string]$Build#,
      #[Parameter(Mandatory = $true, HelpMessage = "Select the Windows Operating System you want information on")][string]$OS
    )

    $url = 'https://docs.microsoft.com/en-us/windows/release-health/release-information'
    $WebResponse = Invoke-WebRequest $url
    $req = ConvertFrom-Html -Content $WebResponse

$tables =  $req.SelectNodes('//table') | Select-Object -skip 2 | Select-Object -first 6

$data2 = @()
foreach ($table in $tables)
{
#$objPropertyNames =  $table.ChildNodes.Elements('th').InnerText
$data = @()
foreach ($tablerow in ($table.Elements('tr') | Select-Object -Skip 1)) {

        $cells = @($tableRow.Elements('td')).InnerText
        if ($cells[0] -like "*&bull;*") {$cells[0] = $cells[0] -replace "  &bull;  ", " - "}
        $obj = New-Object -TypeName PSObject
        $obj | Add-Member -MemberType NoteProperty -Name "Servicing option" -Value $cells[0]
        $obj | Add-Member -MemberType NoteProperty -Name "Availability date" -Value $cells[1]
        $obj | Add-Member -MemberType NoteProperty -Name "OS build" -Value $cells[2]
        $obj | Add-Member -MemberType NoteProperty -Name "Kb article" -Value $cells[3]
        $data+=$obj  
}
$data2+=$data
}

if ($build -eq "AllVersions") {Return $data2}
else {Return $data2 | Where-Object {$_."Os Build" -like "*$build*"}}

}

Set-Alias -Name Get-WRI -Value Get-WindowsReleaseInformation