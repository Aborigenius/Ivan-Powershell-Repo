$wst = get-content .\jr.txt
 Foreach($item in $ws)
 {
  (Get-WmiObject -Class:Win32_ComputerSystem).Model
 }