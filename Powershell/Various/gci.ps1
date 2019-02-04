<# 
.NAME
    Get-ComputerInfo
.SYNOPSIS
    Gets the computer system Information
.INPUTS
    ComputerName

#>
function Get-ComputerInfo
{

Param
(
[Parameter(Mandatory=$true,
    ValueFromPipeline=$true,
    ValueFromPipelineByProperty=$true,
    Position=1)]
    [String[]]
    $Computername
)
#Function Logic:
Get-CimInstance -ComputerName $Computername -ClassName Win32_computersystem 

}