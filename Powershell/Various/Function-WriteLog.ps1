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