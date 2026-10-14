# Referens: Nätverksbryggor på `pve`

Ur `/etc/network/interfaces` på Proxmox-noden.

| Brygga | Adress | Fysisk port | Syfte |
|---|---|---|---|
| `vmbr0` | 10.10.0.2/24, gw 10.10.0.1 | `enp3s0` | Huvud-LAN, VLAN-aware (2–4094) |
| `vmbr1` | 10.10.0.3/24 | `eno1np0` | VM/LXC-nätverk, VLAN-aware (2–4094). De flesta VM:ar (t.ex. cloud-init-mallarna) har `net0` på denna brygga. |
| `vmbr50` | ingen adress, ingen fysisk port | – | Isolerat labbnät för skolprojektet "skamt-sido" (Boiler Room). Trafik lämnar nätet bara genom teamets router-VM `rtr01`. Tillagd 2026-10-01. |

Noden själv nås på `10.10.0.3` (via `vmbr1`) – det är adressen `pve` i SSH-configen pekar på.
