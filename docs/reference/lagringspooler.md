# Referens: Lagringspooler på `pve`

Ur `pvesm status`.

| Namn | Typ | Används för |
|---|---|---|
| `zfs-pve` | zfspool | Standard för VM-/container-diskar (t.ex. `qm clone ... --storage zfs-pve`) |
| `zfs-backup` | zfspool | Backup-pool |
| `local-lvm` | lvmthin | Lokal thin-provisionerad lagring |
| `local` | dir | Nodens lokala filsystem (ISO:er, mallar, snippets m.m.) |
| `NAS` | nfs | Extern NAS över NFS |

Kör `ssh pve "pvesm status"` för aktuella fyllnadsgrader – de ändras över tid.
