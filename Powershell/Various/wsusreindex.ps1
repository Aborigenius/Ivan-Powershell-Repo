[reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration")

$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer();

$wsus.GetUpdates() | Where {$_.IsDeclined -eq $true} | ForEach-Object {$wsus.DeleteUpdate($_.Id.UpdateId.ToString()); Write-Host $_.Title removed }
