# Driftdokumentation – test-sstab

Dokumentation av testservern **test-sstab** (VMID 114 på Proxmox-noden `pve`), skapad för skoluppgiften Boiler Room. Omfattar bara den här servern – inte resten av Proxmox-värden.

Strukturerad enligt [Diátaxis](https://diataxis.fr/): fyra mappar för fyra olika behov.

| Mapp | Frågan den svarar på | Exempel |
|---|---|---|
| `tutorials/` | "Hur lär jag mig genom att göra?" | Skapa och starta test-sstab från grunden |
| `how-to/` | "Hur löser jag den här specifika uppgiften?" | Kom åt test-sstab och hitta dess IP |
| `reference/` | "Vad finns, exakt?" | test-sstabs specifikation (VMID, mall, resurser) |
| `explanation/` | "Varför är det byggt så?" | Varför en cloud-init-mall istället för manuell install |

Branch: `daniel` – Daniels arbetsgren för att dokumentera test-sstab. Merga mot `main` när ett avsnitt är klart.
