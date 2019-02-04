<#
    .Synopsis
    Get A List Of Inactive Computers 
    .DESCRIPTION
    Get A List Of Inactive Computers where no one log in in the last 90 days
    .EXAMPLE
    Load The Function and Run cmdlet
    .EXAMPLE
    If you want the list exported use 
	| Out-File Inactive.csv
	after the script
	.Author 
	Ivan Spiridonov
	
#>
Function ListInactive {
    Get-ADComputer -Filter {LastLogonTimeStamp -lt $time -and name -notlike "tlk*" -and name -notlike "nuhqsna*" -and name -notlike "unsfmws06*" -and OperatingSystem -notlike "Windows Server*" -and name -notlike "MININT*"} | Sort-Object name | Select-Object -ExpandProperty Name
}

Function Get-InactiveComputers {
    [cmdletbinding()]
    param(
        [string]$date
    )
    Clear-Host

    Write-Host " 1. Choose how many days to go back"
    Write-Host " 2. or accept the default (90)"

    $choice = Read-Host -Prompt "Enter Your Choice" 
    if ($choice -eq "1") {
        $daysToGoBack = Read-Host -Prompt "Enter Days" 
        $time = (Get-Date).AddDays( - $daysToGoBack)
    }
    else {
        $time = (Get-Date).AddDays(-90)
    }
    ListInactive
    Write-Host `n

    Write-Host " 1. Do you want to disable and move them to Inactive OU?" 
    Write-Host " 2. Quit" `n
    $choice = Read-Host -Prompt "Enter Your Choice" 

    if ($choice -eq "1") {

        ListInactive | Move-ADObject -TargetPath "OU=Inactive,OU=Workstations,OU=NHQSA-NU-BUTMIR,DC=u131,DC=nato,DC=int"
 
        Get-ADComputer -SearchBase "OU=Inactive,OU=Workstations,OU=NHQSA-NU-BUTMIR,DC=u131,DC=nato,DC=int" -filter * | Disable-AdAccount
    } 

    else {
        Write-Host "Quiting, bye bye"
    }
}