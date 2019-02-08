#Requires -Version 3
<#
.SYNOPSIS
  Creates html Report for remote computer/computers

.DESCRIPTION
  Creates html Report for remote computer/computers

.PARAMETER <Parameter_Name>
    ComputerName

.INPUTS
  ComputerName, one or many seperated by comma (,)
  Accepts variable containg computer names as well

.OUTPUTS
  HTML file in the follwoing Format:
  COMPUTERNAMEHTMLReport<TodaysDate>.html

.NOTES
  Version:        1.0
  Author:         Ivan Spiridonov
  Creation Date:  08-Feb-2019
  Purpose/Change: Initial script development
  Not Working for the local workstation (yet)
  
.EXAMPLE
  Get-info.ps1 -ComputerName pc1,pc,pc3
#>
[cmdletbinding()]
Param(
    [string[]]$ComputerName
    # $Name,
    # $Value,
    # [ValidateNotNull()]
    # [System.Management.Automation.PSCredential]
    # [System.Management.Automation.Credential()]
    # $Credential = [System.Management.Automation.PSCredential]::Empty
)
Function Get-SystemInfo {

    Write-Host "Starting Report on: $pc"
     
    #this function has no real error handling
    $cs = Get-CimInstance -ClassName Win32_computersystem -ComputerName $pc  
    #this assumes a single processor
    $proc = Get-CimInstance -ClassName win32_processor -ComputerName $pc 
    #Get-CimInstance -ClassName Win32_physicalMedia | Select-Object Tag, SerialNumber
    $data = [ordered]@{
        TotalPhysicalMemGB   = $cs.TotalPhysicalMemory / 1GB -as [int]
        NumProcessors        = $cs.NumberOfProcessors
        NumLogicalProcessors = $cs.NumberOfLogicalProcessors
        HyperVisorPresent    = $cs.HypervisorPresent
        DeviceID             = $proc.DeviceID
        Name                 = $proc.Name
        MaxClock             = $proc.MaxClockSpeed
        L2size               = $proc.L2CacheSize
        L3Size               = $proc.L3CacheSize
  
    }

    Invoke-Command -ComputerName $pc -ScriptBlock { Get-CimInstance Win32_DiskDrive | ForEach-Object {
            $disk = $_
            $partitions = "ASSOCIATORS OF " +
            "{Win32_DiskDrive.DeviceID='$($disk.DeviceID)'} " +
            "WHERE AssocClass = Win32_DiskDriveToDiskPartition"
            Get-CimInstance -Query $partitions  | ForEach-Object {
                $partition = $_
                $drives = "ASSOCIATORS OF " +
                "{Win32_DiskPartition.DeviceID='$($partition.DeviceID)'} " +
                "WHERE AssocClass = Win32_LogicalDiskToPartition"
                Get-CimInstance -Query $drives | ForEach-Object {
                    New-Object -Type PSCustomObject -Property @{
                        Disk        = $disk.DeviceID
                        #DiskSize    = $disk.Size
                        DiskModel   = $disk.Model
                        Partition   = $partition.Name
                        RawSize     = $partition.Size
                        DriveLetter = $_.DeviceID
                        VolumeName  = $_.VolumeName
                        Size        = [math]::Round(($_.Size / 1GB), 2) #'{0:d} GB' -f [int]($_.Size / 1GB)
                        FreeSpace   = [math]::Round(($_.FreeSpace / 1GB), 2)
                              
                    }
                }
            }
        }

    }
    Get-CimInstance -ClassName Win32_physicalMedia -ComputerName $pc | ForEach-Object { $hd = $_
        New-Object -TypeName PSCustomObject -Property @{        
            Disk    = $hd.Tag
            Serial = $hd.SerialNumber
        }
    }
    # Invoke-Command -ComputerName $pc -ScriptBlock {Get-CimInstance -ClassName Win32_physicalMedia | ForEach-Object { $hd = $_
    #   New-Object -TypeName PSCustomObject -Property @{
    #     Tag = $hd.Tag
    #     Serial = $hd.SerialNumber
    #   }
    #   }}
}
foreach ($pc in $ComputerName) {
    
    if (Test-Connection -ComputerName $pc -Count 1 -Quiet -ErrorAction SilentlyContinue) {
        # If Console Output is needed uncomment the next line
        # Get-SystemInfo $pc
        $fragments = @()
        $imagePath = ".\icons\006-gear.png"
        $imageBits = [Convert]::ToBase64String((Get-Content $ImagePath -Encoding Byte))
        $ImageFile = Get-Item $ImagePath
        $ImageType = $ImageFile.Extension.Substring(1) #strip off the leading .
        $ImageTag = "<Img src='data:image/$ImageType;base64,$($ImageBits)' Alt='$($ImageFile.Name)' style='float:left' width='50' height='50' hspace=10>"
        $fragments += $ImageTag
        #adjust spacing - takes trial and error
        $fragments += "<br><br>"
        $fragments += "<H2>OS Info</H2>"
        $fragments += Get-CimInstance -ClassName win32_operatingsystem -ComputerName $pc |
            Select-Object  pscomputername, @{Name = "Operating System"; Expression = {$_.Caption}}, Version, @{Name = "Install Date"; Expression = {$_.ConverttoDateTime($_.InstallDate)} } |
            ConvertTo-Html -Fragment -As List
        $fragments += "<H2>System Info</H2>"
        $fragments += Get-SystemInfo -ComputerName $pc | ConvertTo-Html -Fragment -As List
        $filename = $pc.ToString().ToUpper() + "HtmlReport" + $((Get-Date).ToString('MM-dd-yyyy'))
        ConvertTo-HTML -Title "OS Info" -body "$fragments" -PostContent "<H5><i>Generated on: $((Get-Date -Format f)) by $env:UserName</i></H5>" -CSSUri "ps.css" | Set-Content "$filename.html"
    }
}