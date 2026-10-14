# Referens: VM- och LXC-inventering på `pve`

Hämtad med `ssh pve "qm list"` / `ssh pve "pct list"`. VMID-intervall verkar grupperade (se [explanation/vmid-struktur.md](../explanation/vmid-struktur.md)) – uppdatera tabellen när noden ändras, den blir fort inaktuell.

## VM:ar (`qm list`)

| VMID | Namn | Typ |
|---|---|---|
| 100 | dockett | prod-tjänst |
| 103 | lgtm | prod-tjänst (Grafana LGTM-stack?) |
| 104 | redhat | – |
| 105 | vlan10 | – |
| 106 | haos | Home Assistant OS |
| 107 | logger | – |
| 108 | Holmdigital | – |
| 109 | holmdigital-replica | replika |
| 110 | monitoring | prod-tjänst |
| 111 | siteInclusive | – |
| 112 | ub26 | – |
| 113 | holmdigital | – |
| 114 | test-sstab | testmiljö (klonad från `ubuntu-2404-cloudinit`, 2026-10-14) |
| 203 | test1 | test |
| 205 | carbcalc | – |
| 207 | new | – |
| 208 | ub-chas-srv01 | jump host, se [explanation/atkomstarkitektur.md](../explanation/atkomstarkitektur.md) |
| 209 | kveld | – |
| 211 | paas | Coolify/PaaS |
| 220 | tf-test-vm | Terraform-test |
| 301/302 | srv-linux / srv-windows | labb |
| 311/312 | iscx26-linux / iscx26-win | labb (iscx26) |
| 321/322 | iscx26-vg-linux / iscx26-vg-win | labb (iscx26) |
| 399 | malltest | – |
| 9000–9003, 9010 | cloud-init-mallar | se [reference/cloudinit-mallar.md](../reference/cloudinit-mallar.md) |

## Containrar (`pct list`)

| VMID | Namn |
|---|---|
| 101 | gitea |
| 102 | prometheus |
| 200 | openldap |
| 201 | ansible |
| 202 | technitiumdns |
| 204 | proxmox-backup-server |
| 206 | postgresql |
| 210 | hd-failover |
