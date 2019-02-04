#Install-WindowsFeature AD-Domain-Services
Install-ADDSDomainController  `
 -CreateDnsDelegation:$false `
 -DatabasePath "C:\Windows\NTDS" `
-DomainName "domain.some.com" `
-InstallDns:$true `
 -LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$false `
 -SysvolPath "C:\Windows\SYSVOL" `
 -NoGlobalCatalog:$false `
 -SafeModeAdministratorPassword `
  (ConvertTo-SecureString "UhavedoneitN0w" -AsPlainText -Force) `
