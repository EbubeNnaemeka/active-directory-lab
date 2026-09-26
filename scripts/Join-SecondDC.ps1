#Requires -RunAsAdministrator
<#
Promotes a second server to an additional domain controller in an existing
domain, for redundancy. Run on DC02 after joining it to the domain as a
member server with a static IP pointing at DC01 for DNS.
#>

param(
    [string]$DomainName = "corp.lab",
    [Parameter(Mandatory = $true)]
    [PSCredential]$DomainCredential,
    [Parameter(Mandatory = $true)]
    [SecureString]$SafeModePassword
)

Install-WindowsFeature -Name AD-Domain-Services, DNS -IncludeManagementTools

Import-Module ADDSDeployment

Install-ADDSDomainController `
    -DomainName $DomainName `
    -Credential $DomainCredential `
    -SafeModeAdministratorPassword $SafeModePassword `
    -InstallDns:$true `
    -DatabasePath "C:\Windows\NTDS" `
    -LogPath "C:\Windows\NTDS" `
    -SysvolPath "C:\Windows\SYSVOL" `
    -NoGlobalCatalog:$false `
    -Force:$true

# After reboot, verify replication:
#   repadmin /replsummary
#   Get-ADDomainController -Filter *
