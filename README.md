# PScripts
A small collection of Powershell scripts for various purposes

Script list:
 * TexEdit

## TexEdit
This script creates sessions for TeX-Studio out of single .tex files. The session will contain all files, which are imported by this file. This script is currently only useful when used together with a custom TeX style. The TeX style for which this script was developed imports chapters by name after defining a relative chapter directory like this: *This is a private style which isn't openly available, so for now the script isn't of much use for anyone else.*
```
\chapterpath{../../chapters}

\import{introduction}
\import{main_part}
```

### Planned features

#### Add BibTeX files to session
The script should optionally the referenced .bib file.

#### Support other import stlyes as well 
Extend the script so that it recognizes other import statements (`\input`).