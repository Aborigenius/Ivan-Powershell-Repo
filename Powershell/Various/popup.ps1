$wshell = New-Object -ComObject Wscript.Shell
$wshell.Popup("Operation Completed",0,"Done",0x4)
switch ($wshell) {
6 {write-host "Blah"}
}