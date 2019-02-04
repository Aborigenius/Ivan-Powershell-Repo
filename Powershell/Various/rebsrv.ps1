$srv = get-content srvstoreboot.txt

foreach ($s in $srv){
restart-computer -computername $s -force
}