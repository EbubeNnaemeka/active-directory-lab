#Requires -RunAsAdministrator
<#
Stands up the first domain controller: installs AD DS, DNS, and DHCP roles,
then promotes the server to a new forest root domain.
Run locally on DC01 after the OS install and static IP are configured.
#>

param(
    [string]$DomainName = "corp.lab",
    [string]$NetbiosName = "CORP",
    [Parameter(Mandatory = $true)]
    [SecureString]$SafeModePassword
)

Install-WindowsFeature -Name AD-Domain-Services, DNS, DHCP -IncludeManagementTools

Import-Module ADDSDeployment

Install-ADDSForest `
    -DomainName $DomainName `
    -DomainNetbiosName $NetbiosName `
    -SafeModeAdministratorPassword $SafeModePassword `
    -InstallDns:$true `
    -DatabasePath "C:\Windows\NTDS" `
    -LogPath "C:\Windows\NTDS" `
    -SysvolPath "C:\Windows\SYSVOL" `
    -Force:$true

# Server reboots automatically after promotion.
# After reboot, configure the DHCP scope with:
#   Add-DhcpServerv4Scope -Name "Corp-Lab-Scope" -StartRange 10.10.10.100 -EndRange 10.10.10.200 -SubnetMask 255.255.255.0
#   Add-DhcpServerInDC -DnsName "dc01.corp.lab"
#   Set-DhcpServerv4OptionValue -DnsDomain $DomainName -DnsServer 10.10.10.10
