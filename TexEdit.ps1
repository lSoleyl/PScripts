$scriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
$INCLUDE = "$scriptDir\psinclude"
$CONFIG = "$scriptDir\psconfig"
$configFile = "$CONFIG\TexEdits.xml"

. "$INCLUDE\console.ps1"
. "$INCLUDE\tex_session.ps1"

## Config functions
function ConfigEntry($file, $name) {
  return New-Object PSObject -Property @{
    File = $file
    Name = $name
  }
}

function GetConfigList {
  if (Test-Path $configFile) {
    return Import-Clixml $configFile
  }
  return @()
}

function SaveConfig($cfg) {
  $cfg | Export-Clixml $configFile
}


$cfg = GetConfigList





Write-Host "TexEdit v0.1"
Write-Host "