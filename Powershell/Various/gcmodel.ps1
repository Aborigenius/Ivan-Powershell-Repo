$computers = get-content .\JR.txt | sort

foreach($computer in $computers)
{
    Invoke-Command -ComputerName $computer -ScriptBlock {
        (Get-WmiObject -Class:Win32_ComputerSystem).Model
    }
}

Register-PSSessionConfiguration -Name Microsoft.PowerShell