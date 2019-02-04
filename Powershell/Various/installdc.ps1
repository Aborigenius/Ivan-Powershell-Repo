#Install-WindowsFeature AD-Domain-Services
Install-ADDSDomainController  `
 -CreateDnsDelegation:$false `
 -DatabasePath "C:\Windows\NTDS" `
-DomainName "m131.nato.int" `
-InstallDns:$true `
 -LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$false `
 -SysvolPath "C:\Windows\SYSVOL" `
 -NoGlobalCatalog:$false `
 -SafeModeAdministratorPassword `
  (ConvertTo-SecureString "Uh@veD0NEitNow" -AsPlainText -Force) `
