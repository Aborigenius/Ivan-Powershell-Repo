#Check Service After Reboot

#Get Servers with Exchange (exch) In their name

$exchSrvs = Get-ADComputer -Filter {Name -like "*EXCH*"} | Sort-Object name | Select-Object -expandproperty name

foreach ($server in $exchSrvs)
{
$services = Get-Service -Name back*,msexch* -Exclude backupexecm*,MSExchangeImap4, MSExchangePop3 -ComputerName $server 
Write-Host -ForegroundColor Yellow $server

foreach ($service in $services)
{
    if ($service.Status -eq "Running") 
    {  
    Write-Host -ForegroundColor green $service.name "is running"
    Write-Log -Message "Service $service is running on $server"   
    }
    elseIf ($service.status -eq "Stopped") 
    {
    Write-Host -BackgroundColor Red $service.Name "is stopped, will try to start it!"
    $service.start() 
    Write-Log -Message "Service $service started"
    }
    }
}

#Get rest of the servers and check backupExec Service
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
function Write-Log {
    param (
        [Parameter(Mandatory)]
        [string]$Message,
        
        [Parameter()]
        [ValidateSet("1", "2", "3")]
        [int]$Severity = 1 ## Default to a low severity. Otherwise, override
    )
    
    $line = [pscustomobject]@{
        "DateTime" = (Get-Date)
        "Message"  = $Message
        "Severity" = $Severity
    }
    
    ## Ensure that $LogFilePath is set to a global variable at the top of script
    #Export the results in csv file.
    $line | Export-Csv -Path $LogFilePath -Append -NoTypeInformation

}