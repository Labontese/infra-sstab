# How-to: Komma åt test-sstab

test-sstab körs på Proxmox-noden `pve`, så du går alltid via den noden – du SSH:ar inte direkt till servern utan att först veta dess IP.

## 1. Kom åt `pve`

SSH-aliaset `pve` väljer väg automatiskt: hemma (samma LAN) går det direkt till noden, borta hoppar det via jump-hosten `ub-chas-srv01` över Tailscale. Du behöver bara köra:
```
ssh pve "qm status 114"
```

## 2. Hitta test-sstabs IP-adress

Enklast via guest agent:
```
ssh pve "qm guest cmd 114 network-get-interfaces"
```

Svarar den `QEMU guest agent is not running` (vanligt de första minuterna efter start, se [reference/test-sstab-specifikation.md](../reference/test-sstab-specifikation.md)), slå upp MAC-adressen i ARP-tabellen på noden istället:
```
ssh pve "qm config 114 | grep net0"          # ger MAC-adressen
ssh pve 'ip neigh show | grep -i "<mac-i-gemener>"'
```
En rad med en `10.10.x.x`-adress (inte `fe80::...`) är IPv4-adressen.

## 3. SSH in på servern

```
ssh root@<ip-från-steg-2>
```
(din publika nyckel måste vara satt enligt [tutorials/skapa-och-starta-test-sstab.md](../tutorials/skapa-och-starta-test-sstab.md)).
