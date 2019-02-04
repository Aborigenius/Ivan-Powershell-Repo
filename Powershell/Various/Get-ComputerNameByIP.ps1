function Get-ComputerNameByIP {
    param(
        $IPAddress = $null
    )
    BEGIN {
    }
    PROCESS {
        if ($IPAddress -and $_) {
            throw 'Please use either pipeline or input parameter'
            break
        } elseif ($IPAddress) {
            ([System.Net.Dns]::GetHostbyAddress($IPAddress)).HostName
        } elseif ($_) {
            [System.Net.Dns]::GetHostbyAddress($_).HostName
        } else {
            $IPAddress = Read-Host "Please supply the IP Address"
            [System.Net.Dns]::GetHostbyAddress($IPAddress).HostName
        }
    }
    END {
    }
}