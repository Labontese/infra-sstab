# Förklaring: Mönstret i VMID-numreringen

VMID:erna på `pve` är inte formellt dokumenterade som ett schema någonstans i Proxmox, men ett mönster syns i [reference/vm-lxc-inventering.md](../reference/vm-lxc-inventering.md):

- **100–199**: långlivade tjänster/VM:ar (t.ex. `dockett`, `monitoring`, `holmdigital`-varianter).
- **200–299**: test/dev-VM:ar och enstaka LXC-tjänster (`ansible`, `openldap`, `test-sstab` hamnade här som nästa lediga ID, 114, snarare än 200-serien – `pvesh get /cluster/nextid` fyller alltid på närmast efter högsta befintliga ID under 200, inte efter ett "rätt" intervall).
- **300–399**: labbmiljöer för kurser/projekt (`iscx26-*`, `srv-linux`/`srv-windows`).
- **9000+**: mallar (`template: 1`), aldrig tänkta att köras som riktiga maskiner.

Slutsats: numreringen är en konvention som upprätthålls manuellt, inte något Proxmox tvingar fram. `pvesh get /cluster/nextid` ger bara nästa lediga ID totalt sett (här blev det 114, inte ett ID i 200-serien) – vill man hålla konventionen måste man välja VMID manuellt vid kloning istället för att lita på `nextid`.
