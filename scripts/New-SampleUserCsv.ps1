<#
.SYNOPSIS
    Generates a CSV of realistic sample users for New-BulkADUsers.ps1.
.DESCRIPTION
    Produces -Count users spread across departments with unique
    SamAccountNames. The same -Seed always gives the same file, so the lab
    can be rebuilt identically. Runs anywhere PowerShell 7 does.
.EXAMPLE
    .\New-SampleUserCsv.ps1 -Count 500 -OutputPath ..\data\users-500.csv
#>
[CmdletBinding()]
param(
    [ValidateRange(1, 10000)]
    [int]$Count = 500,
    [string]$OutputPath = (Join-Path $PSScriptRoot '..' 'data' 'users-500.csv'),
    [int]$Seed = 2026
)

$firstNames = 'James', 'Mary', 'Wei', 'Priya', 'Carlos', 'Aisha', 'Liam', 'Sofia', 'Chinedu', 'Hannah', 'Mateo', 'Fatima',
'Noah', 'Olivia', 'Arjun', 'Yuki', 'Kwame', 'Elena', 'Omar', 'Grace', 'Daniel', 'Amara', 'Lucas', 'Mei', 'Ethan', 'Zara'
$lastNames = 'Smith', 'Chen', 'Patel', 'Garcia', 'Okafor', 'Nguyen', 'Brown', 'Kim', 'Singh', 'Martin', 'Adeyemi', 'Rossi',
'Tremblay', 'Roy', 'Wilson', 'Khan', 'Lee', 'Mensah', 'Silva', 'Cohen', 'Dubois', 'Ali', 'Taylor', 'Ivanova', 'Walker'
$departments = [ordered]@{
    IT         = @{ Weight = 15; Titles = 'Systems Administrator', 'Help Desk Technician', 'Network Analyst', 'SOC Analyst' }
    Finance    = @{ Weight = 20; Titles = 'Accountant', 'Financial Analyst', 'Payroll Specialist' }
    HR         = @{ Weight = 10; Titles = 'HR Coordinator', 'Recruiter', 'HR Business Partner' }
    Sales      = @{ Weight = 50; Titles = 'Account Executive', 'Sales Representative', 'Sales Manager' }
    Executives = @{ Weight = 5; Titles = 'Director', 'Vice President' }
}

$rng = [System.Random]::new($Seed)
$pool = foreach ($name in $departments.Keys) { , $name * $departments[$name].Weight }
$used = @{}

$rows = for ($i = 0; $i -lt $Count; $i++) {
    $first = $firstNames[$rng.Next($firstNames.Count)]
    $last = $lastNames[$rng.Next($lastNames.Count)]
    $dept = $pool[$rng.Next($pool.Count)]
    $titles = $departments[$dept].Titles

    $base = ($first.Substring(0, 1) + $last).ToLower()
    $sam = $base
    $n = 1
    while ($used.ContainsKey($sam)) { $n++; $sam = "$base$n" }
    $used[$sam] = $true

    [PSCustomObject]@{
        FirstName      = $first
        LastName       = $last
        Department     = $dept
        Title          = $titles[$rng.Next($titles.Count)]
        SamAccountName = $sam
    }
}

$rows | Export-Csv -Path $OutputPath -NoTypeInformation
Write-Verbose "Wrote $Count users to $OutputPath"
Get-Item $OutputPath
