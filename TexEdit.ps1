param( [switch]$add,  #Add a new entry.          Syntax: TexEdit -add [EntryName] [TexFile]
       [switch]$del,  #Remove an existing entry. Syntax: TexEdit -del [EntryName]
       [switch]$e     #opens all relevant directories in the explorer.
     ) 

$scriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
$INCLUDE = "$scriptDir\psinclude"
$CONFIG = "$scriptDir\psconfig"
$configFile = "$CONFIG\TexEdit.xml"
$SESSION_FILE = "$env:temp\session.txss"

. "$INCLUDE\console.ps1"
. "$INCLUDE\tex_session.ps1"

## Config functions
function ConfigEntry($name, $file) {
  return New-Object PSObject -Property @{
    Name = $name
    File = $file
  }
}

# Either read the config file, or create a new config structure
function GetConfig {
  if (Test-Path $configFile) {
    return Import-Clixml $configFile
  }
  return New-Object PSObject -Property @{
    Last = $null
    Entries = @()
  }
}

function SaveConfig($cfg) {
  if (-not (Test-Path $CONFIG)) { 
    md $CONFIG ##Create config directory on demand
  }
  
  $cfg | Export-Clixml $configFile
}

# This function opens all directories of all encountered files
function OpenDirectories($files) {
  $dirs = $files | % { Split-Path $_ } | sort -unique
  $dirs | % { Invoke-Item $_ }
}


function StartSession($texFile) {
  $imports = CreateTexSession $texFile $SESSION_FILE
  Invoke-Item $SESSION_FILE
  if ($e) {
    OpenDirectories $imports
  }
}





#### Program entry ######

$cfg = GetConfig
[array]$entries = $cfg.Entries

Write-Host "TexEdit v1.1a"


### Command line ###

if ($add) { ## Adding an entry
  if ($args.Length -ne 2) {
    yellow "Wrong number of arguments!"
    Write-Host "Usage: TexEdit -add [EntryName] [PathToTexFile]"
    Exit
  }
  
  $id = $args[0]
  $file = $args[1]
  
  if (($entries | where {$_.Name -eq $id}) -ne $null) {
    red "This EntryName is already in use"
    Exit
  } 
  
  $entries += ConfigEntry $id $file
  $cfg.Entries = $entries | sort Name
  SaveConfig $cfg
  green "Successfully added new entry"
  
  Exit
} elseif ($del) { ## Deleting an entry
 if ($args.Length -ne 1) {
   yellow "Wrong number of arguments!"
   Write-Host "Usage: TexEdit -del [EntryName]"
   Exit
 }
 
 $id = $args[0]
 
 $entries = $entries | where { $_.Name -ne $id }
 if ($entries.Length -eq $cfg.Entries.Length) {
   yellow "No entry found for '$id'"
   Exit
 }
 
 $cfg.Entries = $entries
 if (($cfg.Last -ne $null) -and ($cfg.Last.Name -eq $id)) { ##Reset last (if it is removed)
   $cfg.Last = $null 
 }
 
 SaveConfig $cfg
 green "Successfully removed entry"
 Exit
}


### Interactive program flow ###

Write-Host "Select TeX-File:"
Write-Host ""


if ($cfg.Last -ne $null) { 
  Write-Host "[] $($cfg.Last.Name) (last opened)"
  Write-Host ""
}

for($i = 0; $i -lt $entries.Length; ++$i) {
  Write-Host ("[$i] $($entries[$i].Name)")
}

Write-Host ""
Write-Host "[x] Exit"
Write-Host ""
$choice = Read-Host "Choice"

switch ($choice) 
{
  "" {
       if ($cfg.Last -ne $null) {
         StartSession $cfg.Last.File
       } else {
         Exit ##Invalid option
       }
     }
  "x" { Exit }
    
  default { #Index selected
    [int]$i = $choice
    $entry = $entries[$i]
    $cfg.Last = $entry
    SaveConfig $cfg
    
    StartSession $entry.File
  }
}





