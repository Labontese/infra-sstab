# Referens: test-sstab-specifikation

| Fält | Värde |
|---|---|
| VMID | 114 |
| Namn | test-sstab |
| Proxmox-nod | `pve` |
| Skapad från mall | `ubuntu-2404-cloudinit` (VMID 9000) |
| OS | Ubuntu 24.04.5 LTS |
| Disk | 3584 MB, lagring `zfs-pve` |
| Minne | 8096 MB (ursprungligen 2048 MB, uppjusterad manuellt 2026-10-14) |
| CPU | 2 sockets × 8 cores (ursprungligen 2 cores, uppjusterad manuellt 2026-10-14) |
| Nätverksbrygga | `vmbr1` |
| IP-adress | `10.10.0.217` (DHCP, `eth0`) |
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

**Qemu guest agent är inte installerat.** `qm guest cmd 114 ...` svarar alltid "QEMU guest agent is not running", trots att SSH och nätverk fungerar utmärkt – `agent: enabled=1` i VM-konfigurationen säger bara att Proxmox *får* prata med agenten, inte att paketet `qemu-guest-agent` faktiskt finns i avbildningen. Använd SSH eller ARP-uppslag (se [how-to/kom-at-test-sstab.md](../how-to/kom-at-test-sstab.md)) för att hitta IP-adressen istället.

SSH-nycklar sätts inte i mallen – de lades till separat efter kloning med `qm set 114 --sshkeys <fil-på-noden>` (se [tutorials/skapa-och-starta-test-sstab.md](../tutorials/skapa-och-starta-test-sstab.md)). Ett tillfälligt konsollösenord för `root` sattes också via `qm set 114 --cipassword ...` för felsökning via Proxmox-konsolen när nätverket inte kom upp direkt efter en omstart – byt eller ta bort det igen när felsökningen är klar.
