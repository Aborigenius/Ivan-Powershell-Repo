ipmo activedirectory

Function Remove-ExpiredAccounts {
    [CmdletBinding(SupportsShouldProcess=$true)]
    
    param(
        
        [string]$date
    )


    try {
        $global:LogFilePath = ".\Log\Remove-ExpiredAccount_$((Get-Date).ToString("dd-MM-yyyy")).log"
       ## $date = Read-Host -Prompt "Enter The Desired Date in the Following Format Day/Month/Year" 
        $date = Get-Date (Get-Date).AddDays(-30) -Format d
        $now = Get-Date -Format d
        Write-Log -Message "Script Starting..."

        if (isDateTime ($date)) {

 
            if ((get-date $date).Date -gt (get-date $now).Date) {
                Write-Log -Message "Date is not valid! Enter a date before Today!"
                break
            }
        
        }

        $progressCounter = 0
        $totalAccounts = Search-ADAccount -AccountExpired -UsersOnly | where-Object {$_.accountexpirationdate -lt ($date)} | Measure-Object
        Write-Log -Message "Total Account Found: $($totalAccounts.Count)"
        if ($totalAccounts.Count -eq 0) {
            Write-Log -Message "No Expired Accounts Found, Quiting, Bye-Bye!"
            break
        }
        else {
            Write-Log -Message "Querying AD for expired accounts..."
            $users = Search-ADAccount -AccountExpired -UsersOnly  | where-Object {$_.accountexpirationdate -lt ($date)} | Select-Object -expandproperty samaccountname
            Foreach ($user in $users) {
                Write-Log "Removing Home Folder and User account of $($user)"
                Remove-Item \\nuhqsfile1\Homes\$user -ErrorAction SilentlyContinue -Confirm:$false -Recurse -Force 
                $progressCounter++
            }
            Search-ADAccount -AccountExpired -UsersOnly | where-Object {$_.accountexpirationdate -lt ($date)} | Remove-ADObject -Confirm:$false -Recursive 
        }
    
        if ($progressCounter -gt 0) {
            Write-Log -Message "Completed Successfully. $progressCounter accounts removed."
        }
        else {
            Write-Log -Message "No accounts removed, check the log for any issues and carry on."
            Write-Log -Message "Script Stops Now."
        }
    }


    catch {
        Write-Log -Message $_.Exception.Message -Severity 3
        Break
    }
}

function Write-Log {
    param (
        [Parameter(Mandatory)]
        [string]$Message,
        
        [Parameter()]
        [ValidateSet("1", "2", "3")]
        [int]$Severity = 1 ## Default to a low severity. Otherwise, override
    )
    
    $line = [pscustomobject]@{
        "DateTime" = (Get-Date)
        "Message"  = $Message
        "Severity" = $Severity
    }
    
    ## Ensure that $LogFilePath is set to a global variable at the top of script
    #Export the results in csv file.
    $line | Export-Csv -Path $LogFilePath -Append -NoTypeInformation

}
function isDateTime([string]$date) {
    $result = 0
    if (!([DateTime]::TryParse($date, [ref]$result))) {
        $result = $false
        return $result
    }

    $result = $true
    return $result
}
Remove-ExpiredAccounts