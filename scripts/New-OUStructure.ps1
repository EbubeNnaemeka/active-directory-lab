#Requires -Modules ActiveDirectory
<#
.SYNOPSIS
    Builds the departmental OU structure. Safe to re-run.
.DESCRIPTION
    Creates OU=Corp, one OU per department, and Users/Computers sub-OUs in
    each, plus a delegated admin group for the IT OU. Anything that already
    exists is left alone.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string[]]$Departments = @('IT', 'Finance', 'HR', 'Sales', 'Executives')
)

$domainDN = (Get-ADDomain).DistinguishedName

function New-OUIfMissing {
    [CmdletBinding(SupportsShouldProcess)]
    param([string]$Name, [string]$Path)
    $dn = "OU=$Name,$Path"
    if (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$dn'" -ErrorAction SilentlyContinue) {
        Write-Verbose "Exists: $dn"
    }
    elseif ($PSCmdlet.ShouldProcess($dn, 'Create OU')) {
        New-ADOrganizationalUnit -Name $Name -Path $Path -ProtectedFromAccidentalDeletion $true
        [PSCustomObject]@{ Created = $dn }
    }
}

New-OUIfMissing -Name 'Corp' -Path $domainDN
foreach ($dept in $Departments) {
    New-OUIfMissing -Name $dept -Path "OU=Corp,$domainDN"
    foreach ($sub in 'Users', 'Computers') {
        New-OUIfMissing -Name $sub -Path "OU=$dept,OU=Corp,$domainDN"
    }
}

$itPath = "OU=IT,OU=Corp,$domainDN"
if (-not (Get-ADGroup -Filter "Name -eq 'IT-OU-Admins'" -ErrorAction SilentlyContinue) -and
    $PSCmdlet.ShouldProcess('IT-OU-Admins', 'Create delegated admin group')) {
    New-ADGroup -Name 'IT-OU-Admins' -GroupScope Global -GroupCategory Security -Path $itPath
}
