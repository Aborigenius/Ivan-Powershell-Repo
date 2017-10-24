function Convert-WSUSTargetGroup {
<#
.SYNOPSIS
    Converts the ID to a friendl name or friendly name to an ID
.DESCRIPTION
    Converts the ID to a friendl name or friendly name to an ID
.PARAMETER wsusserver
    Name of WSUS server to connect to.
.PARAMETER id
    Determines the name of the group using the supplied ID.
.PARAMETER name
    Determines the ID of the group using the supplied name.
.NOTES
    Name: Convert-WSUSTargetGroup
    Author: Boe Prox
    DateCreated: 24SEPT2010
.LINK
    https://boeprox.wordpress.org
.EXAMPLE
 Convert-WSUSTargetGroup -wsusserver 'server1' -name 'All Computers'
#>
[cmdletbinding(
    DefaultParameterSetName = 'name',
    ConfirmImpact = 'low'
)]
    Param(
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ValueFromPipeline = $True)]
            [string]$wsusserver,
        [Parameter(
            Mandatory = $False,
            Position = 1,
            ParameterSetName = 'id',
            ValueFromPipeline = $False)]
            [string]$id,
        [Parameter(
            Mandatory = $False,
            Position = 2,
            ParameterSetName = 'name',
            ValueFromPipeline = $False)]
            [string]$name
            )
#Load required assemblies
[void][reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration")
#Connect to WSUS server
$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::getUpdateServer($wsusserver,$False)
If ($name) {
    Try {
        Write-Verbose "Searching for ID via name"
        $group = $wsus.GetComputerTargetGroups() | ? {$_.Name -eq $name}
        $group | Select -ExpandProperty ID
        Continue
        }
    Catch {
        Write-Error "Unable to locate $($name)."
        }
    }
If ($id) {
    Try {
        Write-Verbose "Searching for name via ID"
        $group = $wsus.GetComputerTargetGroups() | ? {$_.ID -eq $id}
        $group | Select -ExpandProperty Name
        Continue
        }
    Catch {
        Write-Error "Unable to locate $($id)."
        }
    }
}
