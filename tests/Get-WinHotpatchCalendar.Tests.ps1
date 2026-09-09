BeforeAll {
  . (Join-Path $PSScriptRoot '..' 'WindowsReleaseInformation' 'Public' 'Get-WinHotpatchCalendar.ps1')
  function ConvertFrom-Html { param($Content) }
}

Describe 'Get-WinHotpatchCalendar' {
  It 'uses the nearest 25H2 bold label for a calendar table' {
    $previousHeading = [pscustomobject]@{ InnerText = 'Windows 11, version 21H2' }
    $heading = [pscustomobject]@{ InnerText = 'Version 25H2 (OS build 26200)' }
    $year = [pscustomobject]@{ InnerText = 'Calendar year 2026' }
    $row = [pscustomobject]@{}
    $row | Add-Member ScriptMethod SelectNodes { param($query) @(
      [pscustomobject]@{ InnerText = 'January' },
      [pscustomobject]@{ InnerText = '2026.01 B' },
      [pscustomobject]@{ InnerText = 'Baseline (Restart)' },
      [pscustomobject]@{ InnerText = '2026-01-13' },
      [pscustomobject]@{ InnerText = '26200.7623' },
      [pscustomobject]@{ InnerText = 'KB5074109' }
    ) }
    $table = [pscustomobject]@{}
    $table | Add-Member NoteProperty HeadingNodes @($previousHeading, $heading, $year)
    $table | Add-Member NoteProperty Rows @([pscustomobject]@{}, $row)
    $table | Add-Member ScriptMethod SelectNodes {
      param($query)
      if ($query -eq 'preceding::*[self::h2 or self::h3 or self::h4 or self::h5 or self::h6 or self::strong or self::b]') {
        return $this.HeadingNodes
      }
      if ($query -eq './/tr') { return $this.Rows }
    }
    $document = [pscustomobject]@{}
    $document | Add-Member NoteProperty Tables @($table)
    $document | Add-Member ScriptMethod SelectNodes { param($query) $this.Tables }

    Mock Invoke-WebRequest { 'response' }
    Mock ConvertFrom-Html { $document }

    $result = Get-WinHotpatchCalendar | ConvertFrom-Json

    $result.Version | Should -Be '25H2'
    $result.'Calendar Year' | Should -Be '2026'
  }

  It 'accepts a numeric month filter' {
    $heading = [pscustomobject]@{ InnerText = 'Version 25H2 (OS build 26200)' }
    $year = [pscustomobject]@{ InnerText = 'Calendar year 2026' }
    $row = [pscustomobject]@{}
    $row | Add-Member ScriptMethod SelectNodes { param($query) @(
      [pscustomobject]@{ InnerText = 'August' },
      [pscustomobject]@{ InnerText = '2026.08 B' },
      [pscustomobject]@{ InnerText = 'Hotpatch' },
      [pscustomobject]@{ InnerText = '2026-08-11' },
      [pscustomobject]@{ InnerText = '26200.9106' },
      [pscustomobject]@{ InnerText = 'KB5120994' }
    ) }
    $table = [pscustomobject]@{}
    $table | Add-Member NoteProperty HeadingNodes @($heading, $year)
    $table | Add-Member NoteProperty Rows @([pscustomobject]@{}, $row)
    $table | Add-Member ScriptMethod SelectNodes {
      param($query)
      if ($query -eq 'preceding::*[self::h2 or self::h3 or self::h4 or self::h5 or self::h6 or self::strong or self::b]') {
        return $this.HeadingNodes
      }
      if ($query -eq './/tr') { return $this.Rows }
    }
    $document = [pscustomobject]@{}
    $document | Add-Member NoteProperty Tables @($table)
    $document | Add-Member ScriptMethod SelectNodes { param($query) $this.Tables }

    Mock Invoke-WebRequest { 'response' }
    Mock ConvertFrom-Html { $document }

    $result = Get-WinHotpatchCalendar -Version 25H2 -Month 8 | ConvertFrom-Json

    $result.Version | Should -Be '25H2'
    $result.Month | Should -Be 'August'
    $result.'OS build' | Should -Be '26200.9106'
  }
}
