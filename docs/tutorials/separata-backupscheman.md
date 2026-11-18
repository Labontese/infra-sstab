# Separata backupscheman per avdelning – Windows Server och Samba

Den här guiden visar hur varje avdelning får ett eget automatiskt backupjobb på Windows Server. Backuperna sparas på Ubuntu-servern via Samba. Det befintliga backupschemat i Windows Server Backup lämnas oförändrat.

## Översikt

| Jobb | Tid (förslag) | Källa på Windows | Destination på Samba |
|---|---|---|---|
| Backup-HR | 19:00 | `C:\Fildelning\HR` | `\\192.168.50.50\backups\HR` |
| Backup-Ekonomi | 20:00 | `C:\Fildelning\Ekonomi` | `\\192.168.50.50\backups\Ekonomi` |
| Backup-Ledning | 21:00 | `C:\Fildelning\Ledning` | `\\192.168.50.50\backups\Ledning` |
| Backup-IT | 22:00 | `C:\Fildelning\IT` | `\\192.168.50.50\backups\IT` |
| Backup-Lager | 23:00 | `C:\Fildelning\Lager` | `\\192.168.50.50\backups\Lager` |
| Backup-Gemensamma | 01:00 | `C:\Fildelning\Gemensamma dokument` | `\\192.168.50.50\backups\Gemensamma` |

Tiderna är förslag. Kontrollera att de inte krockar med varandra eller med det befintliga schemat (se steg 5).

### Varför Task Scheduler och `wbadmin start backup`?

- `wbadmin enable backup` skapar eller ändrar *det* dagliga schemat i Windows Server Backup och skulle därmed röra det befintliga schemat. `wbadmin start backup` kör en engångsbackup, och Task Scheduler upprepar den.
- `-vssCopy` gör en kopiebackup. Den påverkar inte historiken för den befintliga backupkedjan (och är standardläget när `-vssFull` inte anges, men vi anger det uttryckligen så att det syns).
- `-include` med en mappsökväg fungerar i Windows Server 2008 R2 och senare. Det finns även `-nonRecurseInclude` om man vill utesluta undermappar.
- Endast en backupoperation kan köras åt gången, därför ska jobben ligga med marginal mellan varandra.

## Förutsättningar

- Windows Server Backup är installerat (se steg 1).
- Windows-kontot som kör jobben är medlem i **Administrators** eller **Backup Operators** och har läsrätt i källmapparna.
- Samba-kontot (`backupuser`) har skrivrätt i `backups` på Ubuntu-servern.
- Ubuntu-servern nås på `192.168.50.50` (SMB, port 445).

## 1. Kontrollera nätverk och funktion

Öppna PowerShell som administratör:

```powershell
Test-NetConnection 192.168.50.50 -Port 445
Get-WindowsFeature Windows-Server-Backup
```

`TcpTestSucceeded` ska vara `True` och funktionen ska vara `Installed`. Saknas den:

```powershell
Install-WindowsFeature Windows-Server-Backup
```

## 2. Spara inloggningen till Samba

Logga in på Windows Server med det Windows-konto som ska köra backupjobben. Kör som administratör (kommandot frågar efter lösenordet, så det hamnar inte i dokumentationen eller i kommandohistoriken):

```cmd
cmdkey /add:192.168.50.50 /user:backupuser /pass
```

Kontrollera att inloggningen sparades:

```cmd
cmdkey /list:192.168.50.50
```

> Inloggningen sparas per Windows-användare. Backupjobben måste därför köras av samma Windows-konto som kör kommandot ovan.
>
> Om Windows inte accepterar `backupuser` kan du prova `192.168.50.50\backupuser` som användarnamn.

## 3. Skapa backupmapparna och testa skrivrätt

```powershell
"HR","Ekonomi","Ledning","Lager","IT","Gemensamma" | ForEach-Object {
    New-Item -ItemType Directory -Path "\\192.168.50.50\backups\$_" -Force | Out-Null
}
Get-ChildItem "\\192.168.50.50\backups"
```

Förväntad struktur:

```
backups/
├── HR/
├── Ekonomi/
├── Ledning/
├── Lager/
├── IT/
└── Gemensamma/
```

Varje avdelning har en egen destination så att olika jobb inte skriver till samma katalog. Testa skrivrätt och städa efter dig:

```powershell
New-Item "\\192.168.50.50\backups\HR\skrivtest.txt" -ItemType File -Value "test" | Out-Null
Remove-Item "\\192.168.50.50\backups\HR\skrivtest.txt"
```

## 4. Kontrollera ledigt utrymme (valfritt)

Vill du kan du kontrollera hur mycket ledigt utrymme som finns på backupdisken innan jobben aktiveras. Kör på Ubuntu-servern:

```bash
df -h
```

## 5. Skapa backupjobben

### Kontrollera det befintliga schemat först

```powershell
Get-WBSchedule -Policy (Get-WBPolicy)
```

Välj tider som inte ligger nära det befintliga schemat.

### Skapa jobben i Task Scheduler

1. Tryck **Win + R**, skriv `taskschd.msc` och tryck Enter.
2. Klicka **Create Task…** (inte *Create Basic Task*).
3. **General:** namn `Backup-HR`, välj *Run whether user is logged on or not* och markera *Run with highest privileges*. Använd samma Windows-konto som i steg 2. Markera inte *Do not store password*, eftersom jobbet behöver nätverksåtkomst.
4. **Triggers:** *New…* → *Daily* → ange tiden → OK.
5. **Actions:** *New…* → *Start a program*.
   - Program/script: `C:\Windows\System32\wbadmin.exe`
   - Add arguments: se tabellen nedan.
6. **Settings:** markera *Run task as soon as possible after a scheduled start is missed* och sätt *If the task is already running* till *Do not start a new instance*.
7. Klicka OK och ange Windows-kontots lösenord när det efterfrågas.

Argument för respektive jobb (klistra in i *Add arguments*):

| Jobb | Add arguments |
|---|---|
| Backup-HR | `start backup -backupTarget:"\\192.168.50.50\backups\HR" -include:"C:\Fildelning\HR" -vssCopy -quiet` |
| Backup-Ekonomi | `start backup -backupTarget:"\\192.168.50.50\backups\Ekonomi" -include:"C:\Fildelning\Ekonomi" -vssCopy -quiet` |
| Backup-Ledning | `start backup -backupTarget:"\\192.168.50.50\backups\Ledning" -include:"C:\Fildelning\Ledning" -vssCopy -quiet` |
| Backup-IT | `start backup -backupTarget:"\\192.168.50.50\backups\IT" -include:"C:\Fildelning\IT" -vssCopy -quiet` |
| Backup-Lager | `start backup -backupTarget:"\\192.168.50.50\backups\Lager" -include:"C:\Fildelning\Lager" -vssCopy -quiet` |
| Backup-Gemensamma | `start backup -backupTarget:"\\192.168.50.50\backups\Gemensamma" -include:"C:\Fildelning\Gemensamma dokument" -vssCopy -quiet` |

## 6. Testa att jobben fungerar

Kör ett jobb direkt och följ resultatet (exemplet gäller HR, gör samma för övriga):

```powershell
Start-ScheduledTask -TaskName "Backup-HR"
wbadmin get status
```

När körningen är klar:

```powershell
Get-ScheduledTaskInfo -TaskName "Backup-HR" | Format-List LastRunTime, LastTaskResult
Get-ChildItem "\\192.168.50.50\backups\HR" -Recurse -Depth 2
wbadmin get versions -backupTarget:"\\192.168.50.50\backups\HR"
```

- `LastTaskResult` = `0` betyder att jobbet lyckades. Annat värde är en felkod.
- Backupen ska finnas i HR:s mapp (Windows Server Backup lägger den under `WindowsImageBackup`).
- Mer detaljer finns i händelseloggen:

```powershell
Get-WinEvent -LogName "Microsoft-Windows-Backup" -MaxEvents 10 | Format-Table TimeCreated, Id, Message -Wrap
```

**Test med utloggat konto:** Logga ut, låt jobbet köras vid sin schemalagda tid (eller sätt tillfälligt en trigger några minuter framåt), logga in igen och kontrollera `LastRunTime` och `LastTaskResult` enligt ovan.

Dokumentera varje lyckad körning med datum, backupdestination och resultat (se steg 10).

## 7. Återställningstest

En lyckad backup är inte bevisad förrän en fil har återställts. Skapa en testfil i HR-mappen, kör backupen, återställ filen till en annan plats:

```powershell
"återställningstest" | Out-File "C:\Fildelning\HR\aterstallningstest.txt"
Start-ScheduledTask -TaskName "Backup-HR"
# Vänta tills backupen är klar (wbadmin get status), hämta sedan versionsnumret:
wbadmin get versions -backupTarget:"\\192.168.50.50\backups\HR"
```

Använd värdet under *Version identifier* i stället för `<VERSION>`:

```powershell
wbadmin start recovery -version:<VERSION> -itemType:File -items:"C:\Fildelning\HR\aterstallningstest.txt" -backupTarget:"\\192.168.50.50\backups\HR" -recoveryTarget:"C:\Aterstallningstest" -quiet
Get-Content "C:\Aterstallningstest\aterstallningstest.txt"
```

Ta bort testfilerna när testet är klart.

## 8. Felsökning

| Symptom | Trolig orsak | Åtgärd |
|---|---|---|
| Åtkomst nekad / inloggning misslyckas mot delningen | Den sparade `cmdkey`-inloggningen används inte av backupmotorn, eller kontot saknar skrivrätt | Kontrollera skrivrätt (steg 3). Kvarstår felet, lägg till `-user:backupuser -password:<lösenord>` i kommandot. Observera att lösenordet då lagras i jobbets argument. Begränsa i så fall vem som kan läsa Task Scheduler och dokumentera avvikelsen. |
| Jobbet startar men backupen skapas inte | Annat backupjobb körs samtidigt | Flytta tiderna så att jobben inte överlappar, se `wbadmin get status` |
| Fel om otillräckligt utrymme | Backupdisken (5 GB) är full | `df -h` på Ubuntu, minska omfattning eller rensa gamla backuper |
| `LastTaskResult` ≠ 0 | Rättighetsfel, felaktig sökväg eller backupfel | Läs `Microsoft-Windows-Backup`-loggen (steg 6) |
| Jobbet körs inte när kontot är utloggat | Task Scheduler saknar sparat lösenord | Kontrollera *Run whether user is logged on or not* och att *Do not store password* inte är markerat |

## 9. Viktigt att känna till

- **Behörigheter:** Kontot som kör jobbet måste kunna läsa källmappen och skriva till rätt Samba-katalog, och vara medlem i Administrators eller Backup Operators.
- **Diskutrymme:** Kontrollera ledigt utrymme innan alla jobb aktiveras.
- **Backupversioner:** Windows Server Backup skriver över föregående backup när en ny körning görs till samma nätverksdestination för samma dator. Separata avdelningsmappar är inte versionshantering. Misslyckas en körning kan den gamla backupen redan vara överskriven, och den nya oanvändbar.
- **Åtkomst till backuperna:** Utan `-noInheritAcl` ärver backupmappen rättigheterna från delningen, så alla med åtkomst till `backups` kan läsa alla avdelningars backuper. Begränsa åtkomsten till delningen (HR-, ekonomi- och ledningsdata är känslig).
- **Schema:** Task Scheduler-jobben är separata från det befintliga schemat i Windows Server Backup.
