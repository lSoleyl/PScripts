# PScripts
A small collection of Powershell scripts for various purposes

Script list:
 * TexEdit

## TexEdit
This script creates sessions for TeX-Studio out of single .tex files. The session will contain all files, which are imported by this file. This script is currently only useful when used together with a custom TeX style. The TeX style, this script was developed for, imports chapters by name after defining a relative chapter directory like this: 
```
\chapterpath{../../chapters}

\import{introduction}
\import{main_part}
```
*This is a private style which isn't openly available, so for now the script isn't of much use for anyone else.*

The script now also openes .bib files, imported by the `\bibliography` statement

### Planned features

#### Support other import styles as well 
Extend the script so that it recognizes other import statements (`\input`).