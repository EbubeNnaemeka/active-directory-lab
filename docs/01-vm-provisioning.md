# VM Provisioning Reference

| VM | Role | vCPU | RAM | Disk | Network |
|---|---|---|---|---|---|
| DC01 | Primary DC, DNS, DHCP | 2 | 4GB | 40GB | Internal, static 10.10.10.10 |
| DC02 | Secondary DC (redundancy) | 2 | 4GB | 40GB | Internal, static 10.10.10.11 |
| WIN11-CLIENT | Domain-joined workstation | 2 | 4GB | 40GB | Internal, DHCP |

## Steps (Proxmox)

1. Upload the Windows Server 2022 Evaluation ISO and Windows 11 Evaluation ISO to local storage.
2. Create each VM with the specs above, SCSI controller set to **VirtIO SCSI**, network model **VirtIO (paravirtualized)**.
3. Attach the ISO, install the OS, then install the QEMU guest agent.
4. Set static IPs on DC01/DC02 per the table; DNS on all three points to `10.10.10.10` initially (DC01).
5. Rename computers (`DC01`, `DC02`, `WIN11-CLIENT`) before promoting/joining — renaming after join requires extra steps.

## Steps (VMware Workstation / VirtualBox, if not running Proxmox bare-metal)

Same specs, use a **Host-only** or **Internal Network** adapter so the lab never touches your real LAN. Note virtualization must be enabled in your BIOS/UEFI, and if running nested inside another hypervisor, enable "Virtualize Intel VT-x/EPT" on the VM settings for DC01/DC02 (needed if you later add Hyper-V or WSL nested testing).
