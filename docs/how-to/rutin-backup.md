# Rutin: backup och återställning, SRV-01-DC

Gäller löpande drift av backupen som beskrivs i
docs/how-to/how-to-backup-windows-server.md. Ansvarig: IT-avdelningen
(gruppen gg-it).

## Dagliga kontroller

Görs varje vardagsmorgon.

### 1. Senaste backupen på SRV-01-DC

PowerShell på SRV-01-DC:

```powershell
Get-WBSummary
Get-WBJob -Previous 1
```

Kontrollera:
- `LastBackupTime` är natten som gått, inte äldre
- `LastBackupResultHR` är `0` (lyckades)
- `NextBackupTime` är kl. 03:00 nästa natt

### 2. Arkivet på SRV-02-LNX

```bash
ls -la /srv/samba/arkiv/
```

Kontrollera att det finns ett arkiv daterat idag eller igår (arkivskriptet
körs 07:00, se [Backup skriptet](/scripts/linux/arkivera-backup.sh)) och att storleken är rimlig, cirka 13 GB. Skriptets
egen loggrad (skrivs till syslog/cron-mail) visar OK eller FEL.

## Vid misslyckad backup

1. Läs felet: `Get-WBJob -Previous 1 | Format-List` på SRV-01-DC, eller
   loggraden från arkivskriptet på SRV-02-LNX.
2. Vanliga orsaker att utesluta först:
   - Disken på SRV-02-LNX är full (`df -h /srv/samba`)
   - Nätverket mellan 192.168.50.10 och 192.168.50.50 är nere
   - Samba-tjänsten ligger nere (`systemctl status smbd`)
   - Lösenordet för `backupuser` har gått ut av misstag
     (kontot är satt till `PasswordNeverExpires`, så kontrollera det)
3. Åtgärda och kör backupen manuellt för att bekräfta att felet är löst:

   ```powershell
   wbadmin start backup -backupTarget:\\192.168.50.50\backups `
       -user:backupuser@sost.local -systemState `
       -include:C:\Fildelning,C:\Windows\System32\dhcp\backup -vssFull -quiet
   ```

4. Dokumentera incidenten: datum, orsak, åtgärd, i
   [plats för avvikelselogg, t.ex. ett issue eller en logg under docs/].
5. Om felet berodde på platsbrist, se över `SPARA`-värdet i arkivskriptet
   (#46) eller diskstorleken.

## Återställningsprov

| Vad | Hur ofta | Senast provat |
|---|---|---|
| Återställa en mapp från `C:\Fildelning` | Var 3:e månad | 2026-11-11 (25 sekunder, se how-to-guiden) |
| Återställa DHCP-databasen | Var 3:e månad | Inte ännu provat, se #[DHCP-ärendet] |
| Återställa System State (AD) | Minst en gång per år | Inte ännu provat, kräver omstart i DSRM |

Resultatet skrivs som står i avsnittet **Verifiering** i [How-to-backup-windows-server](/docs/how-to/how-to-backup-windows-server.md) , med datum, vad som
testades och resultatet, på samma sätt som provet 2026-11-11 är
dokumenterat.
