#Name: CheckExchangeServices.ps1
#This is a simple script which search for stopped exchange 2010 services and start them
#Author: Ivan Spiridonov
#Contact me at ivan.spiridonov@nhqsa.nato.int
#version 1.0 - tested only on Exchange 2010
#ToDo List - make it look nicer
#Required - file exchanges.txt must be in the same folder, it contains the names of the servers
################################################################################################

$exchservers = Get-Content .\exchanges.txt
foreach ($server in $exchservers)
{
$services = Get-Service -Name "msexch*" -Exclude MSExchangeImap4, MSExchangePop3 -ComputerName $server 
Write-Host -ForegroundColor Yellow $server
foreach ($service in $services)
{
    if ($service.Status -eq "Running") 
    {  
    Write-Host -ForegroundColor green $service.name "is running"   
    }
    elseIf ($service.status -eq "Stopped") 
    {
    Write-Host -BackgroundColor Red $service.Name "is stopped, will try to start it!"
    $service.start() 
    }
    }
}
