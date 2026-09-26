#Requires -Modules ActiveDirectory
<#
.SYNOPSIS
    Bulk-provisions AD users from a CSV.
.DESCRIPTION
    CSV columns: FirstName,LastName,Department,Title,SamAccountName
    Users land in OU=Users,OU=<Department>,OU=Corp,<domain>. Existing users and
    rows whose department OU is missing are skipped. Every new user must change
    the initial password at first logon.
.EXAMPLE
    $pw = Read-Host -AsSecureString 'Initial password'
    .\New-BulkADUsers.ps1 -CsvPath ..\data\users-500.csv -InitialPassword $pw
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$CsvPath,

    [Parameter(Mandatory)]
    [SecureString]$InitialPassword
)

$domain = Get-ADDomain
$created = 0
$skipped = 0

foreach ($u in Import-Csv -Path $CsvPath) {
    $ouPath = "OU=Users,OU=$($u.Department),OU=Corp,$($domain.DistinguishedName)"

    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouPath'" -ErrorAction SilentlyContinue)) {
        Write-Warning "OU missing for department '$($u.Department)'; skipping $($u.SamAccountName)"
        $skipped++
        continue
    }
    if (Get-ADUser -Filter "SamAccountName -eq '$($u.SamAccountName)'" -ErrorAction SilentlyContinue) {
        Write-Verbose "$($u.SamAccountName) already exists"
        $skipped++
        continue
    }

    if ($PSCmdlet.ShouldProcess($u.SamAccountName, "Create user in $ouPath")) {
        New-ADUser `
            -Name "$($u.FirstName) $($u.LastName)" `
            -GivenName $u.FirstName `
            -Surname $u.LastName `
            -SamAccountName $u.SamAccountName `
            -UserPrincipalName "$($u.SamAccountName)@$($domain.DNSRoot)" `
            -Path $ouPath `
            -Title $u.Title `
            -Department $u.Department `
            -AccountPassword $InitialPassword `
            -ChangePasswordAtLogon $true `
            -Enabled $true
        $created++
    }
}

[PSCustomObject]@{ Created = $created; Skipped = $skipped }
