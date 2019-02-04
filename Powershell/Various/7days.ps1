try {
        $global:LogFilePath = ".\Log\List-ExpiredAccount_$((Get-Date).ToString("dd-MM-yyyy")).log"

$date = Get-Date (Get-Date).AddDays(-7) -Format d -DisplayHint Date

Search-ADAccount -AccountExpired -UsersOnly | where-Object {$_.accountexpirationdate -lt ($date)} | select Name, Samaccountname, AccountExpirationdate | Export-Csv "C:\Powershell\7daysReport.csv" -NoTypeinformation

Send-MailMessage -SmtpServer "nuhqscas1" -From "sysadmin@nhqsa.nato.int" -To "sysadmin@nhqsa.nato.int", "j6helpdesk@nhqsa.nato.int" -Subject "Accounts Expired 7 days ago" -Body "Please Remove them from the distribution group" -Attachments 'C:\Powershell\7daysReport.csv'
}
catch {
        Write-Log -Message $_.Exception.Message -Severity 3
        Break
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