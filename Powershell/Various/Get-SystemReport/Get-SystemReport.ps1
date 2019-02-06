<#PSScriptInfo

.VERSION 0.8.0

.GUID f956f543-ef88-4df1-bbc6-52ab19df984c

.AUTHOR Ivan Spiridonov

.COMPANYNAME ATCO Frontec Europe

.COPYRIGHT Feel Free to use it

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
It's more proof of concept than anything else

.PRIVATEDATA 

#>

<# 

.DESCRIPTION 
 Creates HTML system info report for a single computer. CSS file needed is named ps.css(must reside in the same folder). 

#> 
[cmdletbinding()]
Param(
    [string]$ComputerName,
    $Name,
    $Value,
    [ValidateNotNull()]
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.Credential()]
    $Credential = [System.Management.Automation.PSCredential]::Empty
)

Function Get-SystemInfo {
    if ($ComputerName) { 
        Write-Host "Starting Report on: $ComputerName"
     
        #this function has no real error handling
        $cs = Get-WmiObject -ClassName Win32_computersystem -ComputerName $ComputerName
        $bios = Get-WmiObject -ClassName Win32_bios -ComputerName $ComputerName
        #this assumes a single processor
        $proc = Get-WmiObject -ClassName win32_processor -ComputerName $ComputerName
        #$hddSerial = Get-WmiObject -ClassName win32_physicalMedia | Select-Object -expandproperty SerialNumber
        $disklist = @(Get-WmiObject win32_logicaldisk | Where-Object {$_.drivetype -eq '3'} | `
                Select-Object @{N = 'DriveLetter'; E = {$_.caption}}, `
                description, `
                drivetype, `
                volumename, `
            @{N = 'SizeGB'; E = {[math]::Round(($_.size / 1GB), 2)}}, @{N = 'FreeSpaceGB'; E = {"{0:N2}" -f ($_.FreeSpace / 1GB)}}, `
            @{N = 'PercentFree'; E = {"$([Math]::round((($_.FreeSpace/$_.size) * 100)))%"}} 
			
        ) 
    

    
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
            SerialNumber         = $bios.SerialNumber

        }
   
        New-Object -TypeName PSObject -Property $data

        Foreach ($disk in $disklist) {
            [PSCustomObject] @{
                DriveLetter  = $disk.DriveLetter
                Description  = $disk.Description
                #Drivetype = $disk.Drivetype
                Volumename   = $disk.Volumename
                SizeGB       = $disk.'SizeGB'
                FreeSpaceGB  = $disk.FreeSpaceGB
                PercentFree  = $disk.PercentFree
                Model        = Get-WmiObject -ClassName Win32_DiskDrive -computername $ComputerName |  Select-Object -ExpandProperty Model
                SerialNumber = Get-WmiObject -ClassName win32_physicalMedia -computername $ComputerName | Select-Object -expandproperty SerialNumber
            }
        }
        #if ends here    
    }
    else {
        Write-Host "Computer Name Not Passed on the Command Line"
    } 
}

$fragments = @()
$imagePath = ".\icons\006-gear.png"
$imageBits = [Convert]::ToBase64String((Get-Content $ImagePath -Encoding Byte))
$ImageFile = Get-Item $ImagePath
$ImageType = $ImageFile.Extension.Substring(1) #strip off the leading .
$ImageTag = "<Img src='data:image/$ImageType;base64,$($ImageBits)' Alt='$($ImageFile.Name)' style='float:left' width='60' height='60' hspace=10>"
$fragments += $ImageTag
#adjust spacing - takes trial and error
$fragments += "<br><br>"
$fragments += "<H2>OS Info</H2>"
$fragments += Get-WmiObject -ClassName win32_operatingsystem -ComputerName $ComputerName |
    Select-Object  pscomputername, @{Name = "Operating System"; Expression = {$_.Caption}}, @{Name = "Model"; Expression = {"$($cs.Model)"}}, Version, @{Name = "Install Date"; Expression = {$_.ConverttoDateTime($_.InstallDate)} } |
    ConvertTo-Html -Fragment -As List
$fragments += "<H2>System Info</H2>"
$fragments += Get-SystemInfo -ComputerName $ComputerName | ConvertTo-Html -Fragment -As List
$filename = "HtmlReport" + "($ComputerName)"
ConvertTo-HTML -Title "OS Info" -body "$fragments" -PostContent "<H5><i>Generated on: $((Get-Date -Format f))</i></H5>" -CSSUri "ps.css" | Set-Content "$filename.html"