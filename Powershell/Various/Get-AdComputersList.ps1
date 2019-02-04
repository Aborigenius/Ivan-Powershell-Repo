
<#PSScriptInfo

.VERSION 1.0.0

.GUID 3de9a775-9113-4569-8f3b-e59e5cdb91fc

.AUTHOR Ivan Spiridonov

.COMPANYNAME ATCO Frontec

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
 Pull alphabetically ordered list of all computers in Butmir - No Servers 

#> 
Param() Get-ADComputer -Filter {name -like "unsfmws0*" -and name -notlike "unsfmws06*"} | sort name | select -ExpandProperty Name 




