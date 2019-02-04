if (($PSVersionTable.PSVersion | Select-Object -ExpandProperty Major) -eq  5 -and ($PSVersionTable.PSVersion | Select-Object -ExpandProperty Minor) -eq 1)
{
Write-Host "Installed"
}