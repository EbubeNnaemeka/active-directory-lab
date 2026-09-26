# Ansible Day-2 Configuration

Optional alternative to running the PowerShell scripts by hand. Requires:
- Ansible control node (a small Linux VM works fine)
- `ansible-galaxy collection install microsoft.ad`
- WinRM enabled on target Windows hosts (self-signed cert is fine for a lab — do not reuse this config in production)

Set `domain_dn` and `default_password` in `group_vars/all.yml` (not committed — see `.gitignore`) before running.
