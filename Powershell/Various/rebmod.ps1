$modsrv = Get-Content modsrv.txt
write-host $modsrv

Foreach ($srv in $modsrv)
{
Restart-Computer $srv -Force
}