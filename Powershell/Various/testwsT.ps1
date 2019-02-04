function TestWS {
##file named inactivews.txt in the same folder
$wsToCheck = UNSFMWS0272

foreach ($ws in $wsToCheck){

	if (-Not (Test-Connection -ComputerName $ws -Quiet)){
	Write-Host $ws}
	else{
		Write-Host "It's Alive"
		}

	}

}