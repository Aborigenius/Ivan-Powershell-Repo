function Get-MemberOfTree {
    <#
    .SYNOPSIS
        Get memberOf for an object and present output as a tree.
    .DESCRIPTION
        A recursive function which uses repeated ADSI searches to build a memberOf tree.
    #>

    [CmdletBinding(DefaultParameterSetName = 'ManualSearchRoot')]
    param (
        # A DN or SamAccountName used to start the search.
        [Parameter(Mandatory = $true, Position = 1)]
        [String]$Identity,

        # The root of the current domain by default. A fixed value can be supplied if required. Note that the search root is also used to locate the suer if a DN is not supplied.
        [Parameter(ParameterSetName = 'ManualSearchRoot', Position = 2)]
        [String]$SearchRoot = (([ADSI]'LDAP://RootDSE').defaultNamingContext[0]),

        # Use a Global Catalog to search instead of LDAP (used for forest-wide searches).
        [Alias('GlobalCatalog')]
        [Switch]$GC,

        # Sets the SearchRoot value to the forest root domain taken from RootDSE.
        [Parameter(Mandatory = $true, ParameterSetName = 'AutomaticForestSearchRoot')]
        [Switch]$UseForestRoot,

        #   The character to use to indent values.
        [Parameter(Position = 4)]
        [String]$IndentChar = '  ',

        # The starting indent level (repetition of the IndentCharacter value).
        [Parameter()]
        [UInt32]$IndentLevel = 0,

        [System.Collections.Generic.HashSet[String]]$loopPrevention = (New-Object System.Collections.Generic.HashSet[String])
    )

    if ((Get-PSCallStack)[1].InvocationInfo.InvocationName -ne $myinvocation.InvocationName) {
        '{0}{1}' -f ($IndentChar * $IndentLevel), $Identity
        $IndentLevel++
    }

    $protocol = 'LDAP'
    # Switch the protocol if the GC switch parameter is used.
    if ($GC) {
        $protocol = 'GC'
    }
    if ($UseForestRoot) {
        $SearchRoot = ([ADSI]'LDAP://RootDSE').rootDomainNamingContext[0]
    }

    $searcher = [ADSISearcher]('{0}://{1}' -f $Protocol, $SearchRoot)
    $searcher.PageSize = 1000
    $searcher.PropertiesToLoad.AddRange(@('name', 'distinguishedName', 'objectClass'))
    
    # If the value passed as identity is not an object DN or a GUID treat the value as a sAMAccountName 
    # and execute a search using the SearchRoot and GC parameters.
    $guid = [Guid]::NewGuid()
    if ([Guid]::TryParse($Identity, [Ref]$guid)) {
        $guidHex = $guid.ToByteArray() | ForEach-Object { $_.ToString('X2') }
        $filter = '(objectGuid=\{0})' -f ($guidHex -join '\')
    } elseif ($Identity -notmatch '^CN=.+(?:DC=w+){1,}') {
        $filter = '(|(sAMAccountName={0})(userPrincipalName={0}))' -f $Identity
    }

    # Attempt to resolve the identity to a DN
    if ($filter) {
        try {
            $searcher.Filter = $filter
            $searchResult = $searcher.FindOne()
            if ($searchResult) {
                $Identity = $searchResult.Properties['distinguishedName'][0]
            }
        } catch {
            $pscmdlet.ThrowTerminatingError($_)
        }
    }

    try {
        $searcher.Filter = '(member={0})' -f $Identity
        $searcher.FindAll() | ForEach-Object {
            '{0}{1}' -f ($IndentChar * $IndentLevel), $_.Properties['name'][0]

            if (@($_.Properties['objectClass'])[-1] -eq 'group') {
                $psboundparameters.Identity = $_.Properties['distinguishedName'][0]
                $psboundparameters.IndentLevel = $IndentLevel + 1
                $psboundparameters.LoopPrevention = $loopPrevention

                if ($loopPrevention.Contains($psboundparameters.Identity)) {
                    Write-Debug ('Triggered loop avoidance: {0}' -f $_.Properties['distinguishedName'][0])
                } else {
                    $null = $loopPrevention.Add($psboundparameters.Identity)
                    Get-MemberOfTree @psboundparameters
                }
            }
        }
    } catch {
        throw
    }
}
