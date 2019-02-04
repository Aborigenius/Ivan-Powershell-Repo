$file = Import-Csv.\reservNU.csv -Delimiter ' ' -Header "IP", "ComputerName" 
foreach ($row in $file){
$split = $row
    $IPAddress = $_.Description.split(" ")[0]
    $ComputerName = $_.Description.split(" ")[1]

    $_ | Add-Member -MemberType NoteProperty -Name IPAddress -Value $IPAddress
    $_ | Add-Member -MemberType NoteProperty -Name ComputerName -Value $ComputerName
} Export-Csv 'results.csv'