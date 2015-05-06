## Utilities for working with Tex-Files

function CreateTexSession($texFile, $sessionFile) {
  if (-not (Test-Path $texFile)) {
    red "TeX file doesn't exist!"
    Exit
  }
  
  $imports = GetImports $texFile
  $absTexFile = (Resolve-Path $texFile).Path.Replace('\', '/')
  
  $imports = @($absTexFile) + $imports
  
  $lines = @("[Session]", "FileVersion=1")
  
  for($i = 0; $i -lt $imports.Length; ++$i) {
    $import = $imports[$i].Replace('\', '/')
    $lines += "File$i\FileName=$import"
    $lines += "File$i\Line=0"
    $lines += "File$i\Col=0"
    $lines += "File$i\FirstLine=0"
    $lines += "File$i\FoldedLines="
  }
  
  $lines += "MasterFile="
  $lines += "CurrentFile=$absTexFile"
  $lines += "Bookmarks=@Invalid()"
  $lines += ""
  $lines += "[InternalPDFViewer]"
  $lines += "File="
  $lines += "Embedded=false"
  
  $lines | Out-File -Encoding Default $sessionFile
}


function GetImports($texFile) {
  $importPath = $null
  $texDir = Split-Path -Resolve $texFile 
  
  $imports = @()
  
  $lines = Get-Content $texFile -Encoding UTF8
  foreach($line in $lines) {
    if ($line -match "^\\chapterpath{(.*?)}") { ##Setting importpath
      $importPath = $matches[1].Replace('/', '\')
      $importPath = (Resolve-Path "$texDir\$importPath").Path
    } elseif ($line -match "^\\import{(.*?)}") { ##Import command
      if (-not $importPath) {
        red "ChapterPath not set in $texFile before using first import"
        return @()
      }
      $importName = $matches[1]
      $file = "$importPath\$importName.tex"
      if (Test-Path $file) {
        $imports += $file
      } else {
        yellow "TeX file imports a non existing chapter file '$file'"
      }
    }
  }
  
  return $imports
}

