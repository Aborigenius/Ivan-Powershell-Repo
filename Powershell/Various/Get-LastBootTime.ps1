
Function Get-LastBootTime {
#--------------------------
# .SYNOPSIS
#     Simply Gets The Last Boot Time of a Computer
# .PARAMETER ComputerName
#     A single Computer or an array of computer names.  The default is localhost ($env:COMPUTERNAME).
# .EXAMPLE
#     PS C:\> Get-LastBootTime -ComputerName (Get-Content C:\ServerList.txt) | Format-Table -AutoSize
# .EXAMPLE
#     PS C:\> Get-LastBootTime
# csname      LastBootUpTime
#------      --------------
#UNSFMWS0272 31-Jul-18 5:07:18 PM
##
#PS C:\temp\Scripts> Get-LastBootTime -ComputerName Computername
#
#csname      LastBootUpTime
#------      --------------
#Computername 01-Aug-18 2:53:00 PM
[CmdletBinding()]
Param
(
    [parameter(Mandatory=$false,
    ValueFromPipeline=$true)]
    [String[]]
    $ComputerName = $env:COMPUTERNAME
)
 Foreach ($Computer in $ComputerName) {
Get-WmiObject win32_operatingsystem -ComputerName $Computer | select csname, @{LABEL='LastBootUpTime' ;EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
}
}