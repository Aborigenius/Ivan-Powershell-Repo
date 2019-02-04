
<#PSScriptInfo

.VERSION 1.0.0

.GUID e948ea05-c5c9-4bf6-b44d-847764878f20

.AUTHOR Ivan Spiridonov

.COMPANYNAME ATCO FRONTEC

.COPYRIGHT 

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


#>

<# 

.DESCRIPTION 
 Get Group MemberShip of a user 

#> 
Param()
$username = Read-Host -Prompt "Enter a Username"
$confirmGridView = Read-Host -Prompt "Do You Want a Grid View? Y|N"
if($confirmGridView -eq "y")
{Get-ADPrincipalGroupMembership $username | Select Name | OGV}
else
{Get-ADPrincipalGroupMembership $username | Select Name} 


