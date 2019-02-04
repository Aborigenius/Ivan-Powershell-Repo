function TestWS {
##file named inactivews.txt in the same folder
$wsToCheck = Get-Content .\inactivews.txt

foreach ($ws in $wsToCheck){

	if (-Not (Test-Connection -ComputerName $ws -Quiet)){
	Write-Host $ws}
	else{
		continue
		}

	}

}