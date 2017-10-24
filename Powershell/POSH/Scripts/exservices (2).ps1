#Name: CheckExchangeServices.ps1
#Author: Ivan Spiridonov
#Contact me at ivan.spiridonov@nhqsa.nato.int
#version 1.0 - tested only on Exchange 2010
#ToDo List - make it look nicer
#Required - file exchanges.txt must be in the same folder, it contains the names of the servers, powershell 4.0
#This is a simple script which search for stopped exchange 2010 services and start them


$exchservers = Get-Content .\exchanges.txt

foreach ($server in $exchservers)
{
    Write-Host -ForegroundColor Yellow $server
    $services = Get-Service -name "msexch*" -Exclude MSExchangeImap4, MSExchangePop3 -ComputerName $server 
    foreach($service in $services)
    {
	if ($service.Status -eq "stopped") 
    {Write-Host -ForegroundColor Cyan "Starting" $service.name} 
	elseif ($service.Status -eq "Running") 
	{Write-Host -ForegroundColor green $service.name "is running"}
    }
}