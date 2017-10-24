$computers = Get-Content srv.txt

ForEach ($computer in $computers)

{
 Write-host ("Stoping service on {$computer} ")
  Stop-Service -InputObject $(Get-Service -Computer $computer -Name ccmexec);
 

}
