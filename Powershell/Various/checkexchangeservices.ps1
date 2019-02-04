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
#    if($service.Status -eq "Running")
#        {
#        "-----------------------"
#        "Service is now started"
#        "-----------------------"
#        }
#