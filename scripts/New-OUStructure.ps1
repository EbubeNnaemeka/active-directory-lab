#Requires -Modules ActiveDirectory
<#
Builds a departmental OU structure modeled on a real mid-size company.
Run on any domain-joined machine with RSAT-AD-PowerShell, or on the DC.
#>

$domainDN = (Get-ADDomain).DistinguishedName
$departments = @("IT", "Finance", "HR", "Sales", "Executives")

# Top-level container
New-ADOrganizationalUnit -Name "Corp" -Path $domainDN -ProtectedFromAccidentalDeletion $true

foreach ($dept in $departments) {
    $deptPath = "OU=Corp,$domainDN"
    New-ADOrganizationalUnit -Name $dept -Path $deptPath -ProtectedFromAccidentalDeletion $true

    # Sub-OUs for Users and Computers per department, common enterprise pattern
    $newDeptPath = "OU=$dept,OU=Corp,$domainDN"
    New-ADOrganizationalUnit -Name "Users" -Path $newDeptPath -ProtectedFromAccidentalDeletion $true
    New-ADOrganizationalUnit -Name "Computers" -Path $newDeptPath -ProtectedFromAccidentalDeletion $true
}

# Delegate department OU management to a per-department admin group (example: IT)
New-ADGroup -Name "IT-OU-Admins" -GroupScope Global -GroupCategory Security -Path "OU=IT,OU=Corp,$domainDN"

Write-Host "OU structure created under OU=Corp,$domainDN"
Write-Host "Departments: $($departments -join ', ')"
