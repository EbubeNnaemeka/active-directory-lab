#Requires -Modules ActiveDirectory
<#
Bulk-provisions AD users from a CSV — the whole point of this script is to
demonstrate provisioning at scale instead of clicking "New User" 500 times.
CSV columns: FirstName,LastName,Department,Title,SamAccountName
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$CsvPath,
    [string]$DefaultPassword = "ChangeMe123!"
)

$domainDN = (Get-ADDomain).DistinguishedName
$users = Import-Csv -Path $CsvPath
$securePwd = ConvertTo-SecureString $DefaultPassword -AsPlainText -Force

$created = 0
$skipped = 0

foreach ($u in $users) {
    $ouPath = "OU=Users,OU=$($u.Department),OU=Corp,$domainDN"

    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouPath'" -ErrorAction SilentlyContinue)) {
        Write-Warning "OU not found for department '$($u.Department)', skipping $($u.SamAccountName)"
        $skipped++
        continue
    }

    if (Get-ADUser -Filter "SamAccountName -eq '$($u.SamAccountName)'" -ErrorAction SilentlyContinue) {
        $skipped++
        continue
    }

    New-ADUser `
        -Name "$($u.FirstName) $($u.LastName)" `
        -GivenName $u.FirstName `
        -Surname $u.LastName `
        -SamAccountName $u.SamAccountName `
        -UserPrincipalName "$($u.SamAccountName)@corp.lab" `
        -Path $ouPath `
        -Title $u.Title `
        -Department $u.Department `
        -AccountPassword $securePwd `
        -ChangePasswordAtLogon $true `
        -Enabled $true

    $created++
}

Write-Host "Provisioning complete: $created created, $skipped skipped."
