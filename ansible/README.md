# Ansible Day-2 Configuration

Optional alternative to running the PowerShell scripts by hand. Requires:
- Ansible control node (a small Linux VM works fine)
- `ansible-galaxy collection install microsoft.ad community.general`
- WinRM enabled on target Windows hosts (self-signed cert is fine for a lab — do not reuse this config in production)

Copy `group_vars/all.yml.example` to `group_vars/all.yml` (git-ignored), set the domain values, and store passwords with `ansible-vault encrypt_string`. Then run `ansible-playbook -i inventory.ini site.yml --ask-vault-pass`.

