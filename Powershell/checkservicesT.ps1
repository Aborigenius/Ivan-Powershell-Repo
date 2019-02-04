#Name: CheckExchangeServices.ps1
#This is a simple script which search for stopped exchange 2010 services and start them
#Author: Ivan Spiridonov
#Contact me at ivan.spiridonov@nhqsa.nato.int
#version 1.0 - tested only on Exchange 2010
#ToDo List - make it look nicer
#Required - file exchanges.txt must be in the same folder, it contains the names of the servers
################################################################################################

$servers = Get-ADComputer -filter {name -like "nuhqs*" -and name -notlike "*vh*" -and name -notlike "*nafs1" -and name -notlike "*cmcb"} |Sort-Object name |Select-Object -ExpandProperty name 
foreach ($server in $servers)
{
$services = Get-Service -Name back* -Exclude backupexecm*,BackupExecV* -ComputerName $server
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
