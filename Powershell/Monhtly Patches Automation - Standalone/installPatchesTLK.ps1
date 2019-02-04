#requires -version 2 
<# 
.SYNOPSIS 
   Install Windows updates from C:\Updates folder
.DESCRIPTION 
    Part 2 (intentionally separated) of standalone patches (.cab format) automation
	To unite the script to one piece uncomment row 29-43, however, usb(external hdd) stick cannot be unplugged.
.PARAMETER <Parameter_Name> 
   None
  
 .INPUTS 
   Run start.bat file to start updates installation with no-profile and bypass execution policy
  
 .OUTPUTS 
   None - Log could be implemeted, however, I see no reason for it. 
  
 .NOTES 
   Version:        0.8
   Added OS Archtecture Check  
   Made the script powershell v2 compatible   
   Version:        0.5 
   Purpose/Change: Initial script development 
   Author:         Ivan Spiridonov 
   Email: Ivan.Spiridonov@nhqsa.nato.int
   Creation Date:  22-Jan-2018 
   
    
 .EXAMPLE 
   Run start.bat in elevated command prompt/powershell
 #> 
# $dir = (Get-Item -Path ".\" -Verbose).FullName
# $destination = "$env:homedrive\Updates"
# if((gwmi Win32_OperatingSystem).OSArchitecture -eq "64-bit"){
# Write-Host "I am 64-bit, copying 64-bit patches"
# Copy-Item -Path $dir\x64\*.* -Destination $destination -Recurse 
# }
# else{
# Write-Host "I am 32-bit, copying 32-bit patches"
# Copy-Item -Path $dir\x86\*.* -Destination $destination  -Recurse
# }
# Copy-Item -Path $dir\Generic -Destination $destination -Recurse
# gci $dir |where {! $_.PSIsContainer} | Copy-Item -Destination $destination
# Write-host "Please run start.bat file!" -BackgroundColor Red
# Read-Host {Press Enter To Continue}
# Invoke-Item C:\Updates

Write-Host "Updating Standalone Account"
net user standalone St@ndalone01

$dir = (Get-Item -Path ".\" -Verbose).FullName
#Update Mcafee
Write-Host "Updating Mcafee with the latest .dat file"
$xdat = Get-Item -Path $dir\*.* | Where-Object {$_.Name -match '[0-9]+xdat.exe'}
& $xdat /F /SILENT
 Foreach($item in (ls $dir *.cab -Name))
 {
    echo $item
    $item = $dir + "\" + $item
    dism /online /add-package /packagepath:$item /NoRestart
 }
 foreach($officeCab in (ls $dir\Generic -Name))
 {
 pkgmgr /ip /m:$officeCab /quiet /NoRestart
 }
#Start Mcafee scan
Write-Host "Starting Mcafee scan"
if((gwmi Win32_OperatingSystem).OSArchitecture -eq "32-bit"){
& "C:\Program Files\McAfee\VirusScan Enterprise\scan32.exe" /all /log /autoexit
}
else{
& "C:\Program Files (x86)\McAfee\VirusScan Enterprise\scan32.exe" /all /log /autoexit
}
Write-Host "Removing Everything From C:\Updates"
Get-ChildItem $env:homedrive\Updates -Recurse | Remove-Item -Recurse -Force
#If you want automatic reboot after the patches are applies uncomment the lines below
#Write-Host "Rebooting....."
#restart-computer -Confirm:$false
