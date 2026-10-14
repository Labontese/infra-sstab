# Referens: test-sstab-specifikation

| Fält | Värde |
|---|---|
| VMID | 114 |
| Namn | test-sstab |
| Proxmox-nod | `pve` |
| Skapad från mall | `ubuntu-2404-cloudinit` (VMID 9000) |
| Disk | 3584 MB, lagring `zfs-pve` |
| Minne | 2048 MB |
| CPU | 2 cores |
| Nätverksbrygga | `vmbr1` |
| Cloud-init-användare | `root` (`ciuser: root`) |

## Cloud-init-inställningar (ärvda från mallen)

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

Nätverk: en nic med `dhcp4`, DNS `8.8.8.8` (ur `qm cloudinit dump 114 network`).

**Viktigt:** `package_upgrade: true` gör att servern köar `apt upgrade` vid första boot, vilket kan ta flera minuter. Guest agent kan verka "tyst" under tiden trots att nätverket fungerar – kontrollera trafiken på tap-gränssnittet på noden (`ip -s link show tap114i0`) om du vill bekräfta att den faktiskt gör något.

SSH-nycklar sätts inte i mallen – de lades till separat efter kloning med `qm set 114 --sshkeys <fil-på-noden>` (se [tutorials/skapa-och-starta-test-sstab.md](../tutorials/skapa-och-starta-test-sstab.md)).
