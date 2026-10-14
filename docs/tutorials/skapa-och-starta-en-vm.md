# Tutorial: Skapa och starta en VM från en cloud-init-mall

Mål: du har en ny, körande Ubuntu-VM och vet dess IP-adress.

Proxmox-noden heter `pve` i din SSH-config och har färdiga cloud-init-mallar (VMID 9000–9003, 9010) som du klonar istället för att installera från scratch.

1. Hitta ett ledigt VMID:
   ```
   ssh pve "pvesh get /cluster/nextid"
   ```
2. Klona en mall (här Ubuntu 24.04, VMID 9000) till ett nytt VMID, t.ex. 114:
   ```
   ssh pve "qm clone 9000 114 --name mitt-namn --full true --storage zfs-pve"
   ```
   `--full true` gör en hel kopia istället för en länkad klon, så VM:en inte är beroende av att mallen finns kvar.
3. Lägg in din publika SSH-nyckel för cloud-init-användaren (`ciuser: root` i mallen). Nyckeln måste finnas som en fil *på Proxmox-noden* – ladda upp den först:
   ```
   scp ~/.ssh/id_ed25519.pub pve:/tmp/min-nyckel.pub
   ssh pve "qm set 114 --ciuser root --sshkeys /tmp/min-nyckel.pub && rm /tmp/min-nyckel.pub"
   ```
4. Starta VM:en:
   ```
   ssh pve "qm start 114"
   ```
5. Vänta in IP-adressen. Qemu guest agent tar en stund att starta – särskilt om mallen har `package_upgrade: true` i cloud-init, se [reference/cloudinit-mallar.md](../reference/cloudinit-mallar.md). Fråga agenten upprepat:
   ```
   ssh pve "qm guest cmd 114 network-get-interfaces"
   ```
   Svarar den `QEMU guest agent is not running`, se [how-to/hitta-en-vms-ip-adress.md](../how-to/hitta-en-vms-ip-adress.md) för ett sätt att hitta IP:n ändå (ARP-tabellen).

Klart! Du kan nu SSH:a in med `ssh root@<ip>`.
