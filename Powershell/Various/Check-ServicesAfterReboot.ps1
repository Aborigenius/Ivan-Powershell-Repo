#requires -version 2
<#
.SYNOPSIS
  Script checks all backupExec/Exchange/Spooler Services status and starts them if they are stopped.
  Tested/Works on NU network

.DESCRIPTION
  Not Required, see synopsis

.PARAMETER <Parameter_Name>
  Not Required

.INPUTS
  None

.OUTPUTS
  Log is written in the script forder with <ServicesLog<CurrentDate>.log> name.

.NOTES
  Version:        1.0
  Author:         Ivan Spiridonov
  Creation Date:  04-Feb-2019
  Purpose/Change: Initial script development
  
.EXAMPLE
  Open PowerShell, browse to the script location and run it
#>

$global:LogFilePath = ".\ServicesLog$((Get-Date).ToString("dd-MM-yyyy")).log"
try {
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


    #Get Servers with Exchange (exch) In their name
    $exchSrvs = Get-ADComputer -Filter {Name -like "*EXCH*"} | Sort-Object name | Select-Object -expandproperty name

    foreach ($server in $exchSrvs) {
        $services = Get-Service -Name back*, msexch* -Exclude backupexecm*, backupexecvs*, MSExchangeImap4, MSExchangePop3 -ComputerName $server 
        Write-Host -ForegroundColor Yellow $server

        foreach ($service in $services) {
            if ($service.Status -eq "Running") {  
                Write-Host -ForegroundColor green $service.name "is running"
                Write-Log -Message "Service $service is running on $server"   
            }
            elseIf ($service.status -eq "Stopped") {
                Write-Host -BackgroundColor Red $service.Name "is stopped, will try to start it!"
                Write-Log $service.Name "is stopped, will try to start it!"
                $service.start()
                Start-Sleep -seconds 3
                $service.Refresh()
                if ($service.Status -eq "Running") {
                    Write-Log -Message "Service $service started"
                    Write-Host -ForegroundColor green $service.name "started"
                } 
                else {
                    Write-Log -Message "Service $service still not running, do something"
                    Write-Host -BackgroundColor Red $service.Name "still not running, do something!"
                }
    
            }
        }
    }

    #Get the rest of the servers and check backupExec Service
    $servers = Get-ADComputer -filter {name -like "nuhqs*" -and name -notlike "*vh*" -and name -notlike "*nafs1" -and name -notlike "*cmcb" -and Name -notlike "*EXCH*"} |Sort-Object name |Select-Object -ExpandProperty name 
    ForEach ($server in $servers) {

            #Check PrintSpooler on PrintServers
            if ($server -eq "NUHQSPRNT" -or $server -eq "NUHQSMODPRNT1") {
               
                #If the service is already started, nothing will happen
                Get-Service -name Spooler -ComputerName $server| Start-Service
                Write-Host "Starting service PrintSpooler on $server!"
                continue
            }

    
        $services = Get-Service -Name back* -Exclude backupexecm*, BackupExecV* -ComputerName $server
        Write-Host -ForegroundColor Yellow $server
        foreach ($service in $services) {
            if ($service.Status -eq "Running") {  
                Write-Host -ForegroundColor green $service.name "is running"  
                Write-Log -Message "Service $service is running on $server"  
            }
            elseIf ($service.status -eq "Stopped") {
                Write-Host -BackgroundColor Red $service.Name "is stopped, will try to start it!"
                Write-Log $service.Name "is stopped, will try to start it!"
                $service.start() 
                Start-Sleep -seconds 3
                $service.Refresh()
                if ($service.Status -eq "Running") {
                    Write-Log -Message "Service $service started"
                    Write-Host -ForegroundColor green $service.name "started"
                } 
                else {
                    Write-Log -Message "Service $service still not running, do something"
                    Write-Host -BackgroundColor Red $service.Name "still not running, do something!"
                }
            }
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
}
catch {
    Write-Log -Message $_.Exception.Message -Severity 3
    Break
}