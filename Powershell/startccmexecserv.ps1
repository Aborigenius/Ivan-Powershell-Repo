$computers = Get-Content srv.txt

ForEach ($computer in $computers)

{
 Write-host ("Starting service on {$computer} ")
  Start-Service -InputObject $(Get-Service -Computer $computer -Name ccmexec);

}
