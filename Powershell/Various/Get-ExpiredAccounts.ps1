do{
$date = Read-Host -Prompt "Enter The Desired Date in the Following Format Day/Month/Year" 
$date =(Get-Date -Date $date -Format 'dd/MM/yyyy')
$now = Get-Date -Format 'dd/MM/yyyy'
if((get-date $date).Date -gt (get-date $now).Date)
{Write-Host -BackgroundColor red "Gotha Ya, Are You Trying To Cheat? Enter a date before Today!"}

}While ((get-date $date).Date -gt (get-date $now).Date)
$progressCounter = 0
$totalAccounts = Search-ADAccount -AccountExpired -UsersOnly | where-Object {$_.accountexpirationdate -lt (get-date "$date")} | Measure
if($totalAccounts.Count -gt 0){ 
 Write-Host "Found $($totalAccounts.Count) Accounts!"
 Write-Host "What To Do Next - Valid Options Are: "
 Write-Host -BackgroundColor white -foregroundcolor black "List Accounts - L"
 Write-Host -BackgroundColor DarkGray "Move To Expired OU And Disable Accounts Without Home Folders Removal - M"
 Write-Host -BackgroundColor darkred "Delete Accounts With Home Folders Removal - D" 
 $action = Read-Host -Prompt "Waiting For an Input: "

if($action -eq "D")
{Write-Host "Deleting Accounts"
$users = Search-ADAccount -AccountExpired -UsersOnly  | where-Object {$_.accountexpirationdate -lt (get-date "$date")} | select -expandproperty samaccountname
Foreach ($user in $users){
Write-Progress "Removing Home Folders and Users $($user)"
Remove-Item \\nuhqsfile1\Homes\$user -ErrorAction SilentlyContinue -Confirm:$false -Recurse -Force -WhatIf
$progressCounter++
}
Search-ADAccount -AccountExpired -UsersOnly | where-Object {$_.accountexpirationdate -lt (get-date "$date")} | Remove-AdUser -WhatIf
}
elseif($action -eq "M")
{Write-Host "I am moving, I am moving.....Did you check does Expired OU exist in AD?"
Search-ADAccount -AccountExpired -UsersOnly | where-Object {$_.accountexpirationdate -lt (get-date "$date")} |  Move-ADObject -TargetPath "OU=Expired,OU=Users,OU=NHQSA-NU-BUTMIR,DC=u131,DC=nato,DC=int" 

Search-ADAccount -AccountExpired -UsersOnly | where-Object {$_.accountexpirationdate -lt (get-date "$date")} | Disable-ADAccount -whatif} 
elseif ($action -eq "L")
{Write-Host -BackgroundColor white -foregroundcolor black "Listing, Smart Choice"
Search-ADAccount -AccountExpired -UsersOnly | where-Object {$_.accountexpirationdate -lt (get-date "$date")} | select SamAccountName, LastLogonDate, AccountExpirationDate 
Write-host "Total Accounts: " ($totalAccounts).Count}
else
{Write-Host "No Valid Choice Made, Quiting, Bye-Bye!"}
}
 else{
 Write-Host "No Expired Accounts Found, Quiting, Bye-Bye!"
 }




