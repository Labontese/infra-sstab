# Tutorial: Skapa och starta test-sstab

Mål: du har återskapat test-sstab (eller en liknande VM) från grunden och vet dess IP-adress.

test-sstab (VMID 114) klonades från cloud-init-mallen `ubuntu-2404-cloudinit` (VMID 9000) på Proxmox-noden `pve`, istället för att installeras manuellt.

1. Hitta ett ledigt VMID på noden:
   ```
   ssh pve "pvesh get /cluster/nextid"
   ```
2. Klona mallen till det nya VMID:t:
   ```
   ssh pve "qm clone 9000 114 --name test-sstab --full true --storage zfs-pve"
   ```
   `--full true` gör en hel kopia istället för en länkad klon, så servern inte är beroende av att mallen finns kvar.
3. Lägg in din publika SSH-nyckel för cloud-init-användaren (`ciuser: root`). Nyckeln måste finnas som en fil *på Proxmox-noden* – ladda upp den först:
   ```
   scp ~/.ssh/id_ed25519.pub pve:/tmp/min-nyckel.pub
   ssh pve "qm set 114 --ciuser root --sshkeys /tmp/min-nyckel.pub && rm /tmp/min-nyckel.pub"
   ```
4. Starta servern:
   ```
   ssh pve "qm start 114"
   ```
5. Vänta in IP-adressen. Qemu guest agent kan ta lång tid att svara – mallen kör `apt upgrade` vid första boot (se [reference/test-sstab-specifikation.md](../reference/test-sstab-specifikation.md)). Fråga agenten upprepat:
   ```
   ssh pve "qm guest cmd 114 network-get-interfaces"
   ```
   Svarar den `QEMU guest agent is not running`, se [how-to/kom-at-test-sstab.md](../how-to/kom-at-test-sstab.md) för hur du hittar IP:n via ARP-tabellen istället.

Klart! Du kan nu SSH:a in med `ssh root@<ip>`.
