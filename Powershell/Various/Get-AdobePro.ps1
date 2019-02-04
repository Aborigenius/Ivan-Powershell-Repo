$ws = Get-content ws.txt
$pcname

Expression = { $_.PsComputerName }
}

ForEach ($System in $ws){
    #Pings machine's found in text file
    if (!(test-Connection -ComputerName $System -BufferSize 16 -Count 1 -ea 0 -Quiet))
    {
        Write-Output "$System Offline"
    }
    Else
    {
     #Providing the machine is reachable 
     #Checks installed programs for products that contain Adobe in the name
     Try {Get-WMIObject -Class win32_product -Filter {Name like "%Adobe Acro%"} `
       -ComputerName $System -ErrorAction STOP | 
          Select-Object -Property $pcname,Name,Version }
     Catch {#If an error, do this instead
            Write-Output "$system Offline "}
     #EndofElse
     }
#EndofForEach
}