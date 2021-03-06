<#
.SYNOPSIS
Get Server Information
.DESCRIPTION
This script will get the CPU specifications, memory usage statistics, and OS configuration of any Server or Computer listed in ws.txt.
.NOTES  
The script will execute the commands on multiple machines sequentially using non-concurrent sessions. This will process all servers from ws.txt in the listed order.
The info will be exported to a csv format.
Requires: ws.txt must be created in the same folder where the script is.
File Name  : get-server-info.ps1
Author: Nikolay Petkov
Added HDD info, Ivan, 26 Jan 2017
http://power-shell.com/
#>
#Get the server list
$servers = Get-Content .\ws.txt
#Run the commands for each server in the list
$infoColl = @()
Foreach ($s in $servers)
{
	$HDD = Get-WmiObject -class Win32_LogicalDisk -ComputerName $s -Filter "DriveType=3" | Measure-Object -Property FreeSpace, Size -Sum | % { [Math]::Round(($_.sum / 1GB), 2) } 
	$HDDSerial = Get-WmiObject -Class Win32_PhysicalMedia -ComputerName $s 
	$CPUSerial = Get-WmiObject -class Win32_bios -ComputerName $s 
	$CPUInfo = Get-WmiObject Win32_Processor -ComputerName $s #Get CPU Information
	$OSInfo = Get-WmiObject Win32_OperatingSystem -ComputerName $s #Get OS Information
	#Get Memory Information. The data will be shown in a table as MB, rounded to the nearest second decimal.
	$OSTotalVirtualMemory = [math]::round($OSInfo.TotalVirtualMemorySize / 1MB, 2)
	$OSTotalVisibleMemory = [math]::round(($OSInfo.TotalVisibleMemorySize / 1MB), 2)
	$PhysicalMemory = Get-WmiObject CIM_PhysicalMemory -ComputerName $s | Measure-Object -Property capacity -Sum | % { [Math]::Round(($_.sum / 1GB), 2) }
	Foreach ($CPU in $CPUInfo)
	{
		$infoObject = New-Object PSObject
		#The following add data to the infoObjects.	
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "ServerName" -value $CPU.SystemName
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "Processor" -value $CPU.Name
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "Model" -value $CPU.Description
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "Manufacturer" -value $CPU.Manufacturer
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "PhysicalCores" -value $CPU.NumberOfCores
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "CPU_L2CacheSize" -value $CPU.L2CacheSize
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "CPU_L3CacheSize" -value $CPU.L3CacheSize
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "Sockets" -value $CPU.SocketDesignation
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "LogicalCores" -value $CPU.NumberOfLogicalProcessors
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "OS_Name" -value $OSInfo.Caption
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "OS_Version" -value $OSInfo.Version
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "TotalPhysical_Memory_GB" -value $PhysicalMemory
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "FreeSpace/TotalSize_GB" -value $HDD
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "HDDSerial" -value $HDDSerial.SerialNumber
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "CPUSerial" -value $CPUSerial.SerialNumber
		
		#Add-Member -inputObject $infoObject -memberType NoteProperty -name "TotalVirtual_Memory_MB" -value $OSTotalVirtualMemory
		#Add-Member -inputObject $infoObject -memberType NoteProperty -name "TotalVisable_Memory_MB" -value $OSTotalVisibleMemory
		$infoObject #Output to the screen for a visual feedback.
		$infoColl += $infoObject
	}
}
$infoColl | Export-Csv -path .\FireChief_$_Inventory_$((Get-Date).ToString('MM-dd-yyyy')).csv -NoTypeInformation #Export the results in csv file.