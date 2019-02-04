#requires -version 2 
<# 
.SYNOPSIS 
  Part 1 (intentionally separated) of standalone patches (.cab format) automation
  Copy Patches To A Local Folder (C:\Updates)
 
.DESCRIPTION 
  Copy Windows updates to C:\Updates folder depending on the OS Archtecture
  .cab files are to be located in x86, x64, Generic folder respectfully
   Generic Folder contains office patches
.PARAMETER <Parameter_Name> 
    None
  
 .INPUTS 
    None
  
 .OUTPUTS 
  None - Log could be implemeted, however, I see no reason for it. 
  
 .NOTES 
   Version:        0.8
   Added OS Archtecture Check  
   Made the script powershell v2 compatible   
   Version:        0.5 
   Author:         Ivan Spiridonov 
   Email: Ivan.Spiridonov@nhqsa.nato.int
   Creation Date:  22-Jan-2018 
   Purpose/Change: Initial script development 
    
 .EXAMPLE 
   Run _copyPatches.bat in elevated command prompt/powershell
 #>  

$dir = (Get-Item -Path ".\" -Verbose).FullName
$destination = "$env:homedrive\Updates"
if(-Not (Test-Path -Path $destination))
{ md $destination
}
if((gwmi Win32_OperatingSystem).OSArchitecture -eq "64-bit"){
Write-Host "I am 64-bit, copying 64-bit patches"
Copy-Item -Path $dir\x64\*.* -Destination $destination -Recurse 
}
else{
Write-Host "I am 32-bit, copying 32-bit patches"
Copy-Item -Path $dir\x86\*.* -Destination $destination  -Recurse
}
Copy-Item -Path $dir\Generic -Destination $destination -Recurse
gci $dir |where {! $_.PSIsContainer} | Copy-Item -Destination $destination
Write-host "Please run start.bat file!" -BackgroundColor Red
Read-Host {Press Enter To Continue}
Invoke-Item C:\Updates