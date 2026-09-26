# Group Policy Design

## 1. Password & Lockout Policy (linked at domain root)
- Minimum password length: 12
- Complexity: enabled
- Max password age: 90 days
- Account lockout threshold: 5 invalid attempts
- Lockout duration: 30 minutes

Configure under `Computer Configuration > Policies > Windows Settings > Security Settings > Account Policies`.

## 2. Departmental Drive Mapping (linked per department OU)
Example for Finance OU — maps `F:` to a shared finance folder using Group Policy Preferences:
`User Configuration > Preferences > Windows Settings > Drive Maps`
- Location: `\\dc01\finance$`
- Drive letter: `F:`
- Action: Create/Update
- Item-level targeting: security group `Finance-Users`

## 3. Sales Desktop Restriction (linked to Sales > Users OU)
Restricts Control Panel access and disables Task Manager for the Sales test OU, demonstrating targeted lockdown policy:
`User Configuration > Policies > Administrative Templates > System > Ctrl+Alt+Del Options` → disable Task Manager
`Control Panel` → prohibit access

## 4. Software Restriction Policy (linked to IT > Computers OU)
Example hash-rule blocking a specific unauthorized executable, demonstrating application control fundamentals:
`Computer Configuration > Policies > Windows Settings > Security Settings > Software Restriction Policies`

## Verification
After linking, confirm policy application on a client with:
```
gpupdate /force
gpresult /r
gpresult /h gpo-report.html
```
Export final GPOs for the repo with:
```
Backup-GPO -Name "Corp Password Policy" -Path .\gpo\
```
