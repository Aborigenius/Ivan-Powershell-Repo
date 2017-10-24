$Searcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher
$Searcher.SearchRoot = "LDAP://DC=u131,DC=nato,DC=int"
$Searcher.SearchScope = "subtree"
$Searcher.Filter = "(objectClass=organizationalUnit)"
$Searcher.PropertiesToLoad.Add('Distinguishedname') | Out-Null
$LDAP_OUs = $Searcher.FindAll()
$OUs = $LDAP_OUs.properties.distinguishedname

#Use it like this
#$OUs | foreach { (Get-GPInheritance -Target $_).GPOlinks } | Select @{name = "GPO Name" ; Expression = {$_.Displayname}} , @{name = "Link Location" ; Expression = {$_.Target}} | sort -Property "GPO Name"
#