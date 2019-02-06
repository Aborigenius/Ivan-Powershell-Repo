$disklist = @(Get-WmiObject win32_logicaldisk | Where-Object {$_.drivetype -eq '3'} | Select-Object @{N='DriveLetter';E={$_.caption}},description,drivetype,volumename,@{N='SizeGB';E={[math]::Round(($_.size/1GB),2)}},@{N='FreeSpaceGB';E={"{0:N2}" -f ($_.FreeSpace /1GB)}})

@{N='FreeSpaceGB';E={"{0:N2}" -f ($_.FreeSpace /1GB)}}