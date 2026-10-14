# Referens: Cloud-init-mallar på `pve`

VMID-serien 9000–9010 är rena mallar (`template: 1` i `qm config`), tänkta att klonas, aldrig att köras direkt.

| VMID | Namn | Disk | Minne |
|---|---|---|---|
| 9000 | ubuntu-2404-cloudinit | 3584M | 2048 MB |
| 9001 | ubuntu-2604-cloudinit | 3584M | 2048 MB |
| 9002 | ubuntu-2204-cloudinit | 2200M | 2048 MB |
| 9003 | ubuntu-2004-cloudinit | 2200M | 2048 MB |
| 9010 | winserver2025-tpl | 80 GB | 8192 MB |

Exempelkonfiguration (VMID 9000):
```
agent: enabled=1
ciuser: root
cores: 2
ipconfig0: ip=dhcp
net0: virtio=<mac>,bridge=vmbr1
scsi0: zfs-pve:base-9000-disk-0,size=3584M
scsihw: virtio-scsi-pci
template: 1
```

Cloud-init user-data (`qm cloudinit dump <vmid> user`):
```yaml
#cloud-config
hostname: ubuntu-2404-cloudinit
manage_etc_hosts: true
user: root
disable_root: False
chpasswd:
  expire: False
package_upgrade: true
```

**Viktigt:** `package_upgrade: true` gör att varje nyklonad VM köper `apt upgrade` vid första boot, vilket kan ta flera minuter – guest agent och nätverk kan verka "tysta" under tiden. Se [how-to/hitta-en-vms-ip-adress.md](../how-to/hitta-en-vms-ip-adress.md).

Nätverket sätts via NoCloud-nätverkskonfigurationen (`qm cloudinit dump <vmid> network`): en fysisk nic med `dhcp4`, DNS `8.8.8.8`.

SSH-nycklar sätts inte i mallen – de måste läggas på varje klon separat med `qm set <vmid> --sshkeys <fil-på-noden>` (se [tutorials/skapa-och-starta-en-vm.md](../tutorials/skapa-och-starta-en-vm.md)).
