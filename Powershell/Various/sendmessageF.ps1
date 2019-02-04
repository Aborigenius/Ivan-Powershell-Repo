function Send-ComputerMessage  {   
    param(
    $computername = $null
)
BEGIN {
}
PROCESS {

$computername = Read-Host "Enter computer name "
$msg = Read-Host "Enter your message "
Invoke-WmiMethod -Path Win32_Process -Name Create -ArgumentList "msg * $msg" -ComputerName $computername
}
END {
}
}