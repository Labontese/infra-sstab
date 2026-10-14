# How-to: Hitta en VM:s IP-adress när guest agent inte svarar

Qemu guest agent kan ta lång tid att komma upp efter boot (särskilt om cloud-init kör `package_upgrade: true` och nätverket är trögt, se [reference/cloudinit-mallar.md](../reference/cloudinit-mallar.md)). Så länge testar du med ARP-tabellen på Proxmox-noden istället.

1. Hämta VM:ens MAC-adress ur konfigurationen:
   ```
   ssh pve "qm config <VMID> | grep net0"
   ```
   t.ex. `net0: virtio=BC:24:11:38:47:FB,bridge=vmbr1`

2. Slå upp MAC-adressen i grannlistan (fungerar bara om VM:en redan skickat trafik, t.ex. en DHCP-request):
   ```
   ssh pve 'ip neigh show | grep -i "<mac-adress-i-gemener>"'
   ```
   En rad med en `10.10.x.x`-adress (inte `fe80::...`) är IPv4-adressen. Finns bara `fe80::...`-rader har VM:en ännu inte fått en IPv4-adress via DHCP.

3. Så fort du har en IP, verifiera med guest agent för säkerhets skull:
   ```
   ssh pve "qm guest cmd <VMID> network-get-interfaces"
   ```

**Om det aldrig dyker upp en IPv4-adress:** troligen hänger cloud-init/boot fortfarande (se statusfält i `qm status <VMID>`, och notera att seriekonsolen inte går att läsa icke-interaktivt via `qm terminal` över SSH utan en riktig TTY). Vänta längre, eller starta om VM:en och följ konsolen interaktivt: `ssh pve` och sedan `qm terminal <VMID>`.
