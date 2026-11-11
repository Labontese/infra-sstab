# Separata backupscheman för avdelningar – Windows Server och Samba

Den här guiden visar hur varje avdelning får ett eget automatiskt backupjobb på Windows Server. Backuperna sparas på Ubuntu-servern via Samba. Det befintliga backupschemat i Windows Server Backup lämnas oförändrat.

## 1. Förbered backupmapparna

Öppna **File Explorer** på Windows Server och ange:

```text
\\192.168.50.50\backups
```

Kontrollera att Samba-delningen är tillgänglig och att backupkontot kan skriva där. Skapa följande undermappar om de saknas:

```text
backups/
├── HR/
├── Ekonomi/
├── Ledning/
├── Lager/
├── IT/
└── Gemensamma/
```

Varje avdelning får en egen destination för att undvika att olika backupjobb skriver till samma katalog.

## 2. Spara inloggningen till Samba

Logga in på Windows Server med det Windows-konto som ska köra backupjobben. Öppna **Command Prompt** som administratör och kör:

```cmd
cmdkey /add:192.168.50.50 /user:backupuser
```

Ange Samba-lösenordet när det efterfrågas. Lösenordet ska inte skrivas i dokumentationen eller i backupkommandot.

**Kontroll:** Öppna `\\192.168.50.50\backups` och testa att skapa en tillfällig fil. Ta sedan bort testfilen.

## 3. Skapa ett separat backupjobb för HR

1. Tryck **Win + R**, skriv `taskschd.msc` och tryck **Enter**.
2. Klicka **Create Task** i **Task Scheduler**.
3. Under **General**: ange namnet `Backup-HR`, välj **Run whether user is logged on or not** och markera **Run with highest privileges**.
4. Använd samma Windows-konto som i steg 2. Markera **inte** alternativet *Do not store password* om det visas, eftersom jobbet behöver nätverksåtkomst.
5. Under **Triggers**: klicka **New**, välj **Daily**, ange **19:00** och klicka **OK**.
6. Under **Actions**: klicka **New** och välj **Start a program**.

**Program/script:**

```text
C:\Windows\System32\wbadmin.exe
```

**Add arguments:**

```text
start backup -backupTarget:"\\192.168.50.50\backups\HR" -include:"C:\Fildelning\HR" -vssCopy -quiet
```

7. Klicka **OK** och spara uppgiften. Ange Windows-kontots lösenord om det efterfrågas.

Kommandot säkerhetskopierar HR-mappen till HR:s backupkatalog på Ubuntu.

## 4. Skapa jobb för övriga avdelningar

Upprepa steg 3. Byt **namn, tid, källmapp och backupdestination** enligt tabellen.

| Jobb | Exempeltid | Källa på Windows | Destination på Samba |
|---|---|---|---|
| Backup-HR | 19.00 | `C:\Fildelning\HR` | `\\192.168.50.50\backups\HR` |
| Backup-Ekonomi | 20.00 | `C:\Fildelning\Ekonomi` | `\\192.168.50.50\backups\Ekonomi` |
| Backup-Ledning | 21.00 | `C:\Fildelning\Ledning` | `\\192.168.50.50\backups\Ledning` |
| Backup-IT | 22.00 | `C:\Fildelning\IT` | `\\192.168.50.50\backups\IT` |
| Backup-Lager | 23.00 | `C:\Fildelning\Lager` | `\\192.168.50.50\backups\Lager` |
| Backup-Gemensamma | 01.00 | `C:\Fildelning\Gemensamma dokument` | `\\192.168.50.50\backups\Gemensamma` |

Tiderna är **förslag**. Kontrollera att de inte krockar med varandra eller med det befintliga backupschemat.

## 5. Testa att jobben fungerar

1. Öppna **Task Scheduler Library**.
2. Högerklicka på `Backup-HR` och välj **Run**.
3. Kontrollera körningen och resultatet i Task Scheduler. Vid behov kan status kontrolleras med `wbadmin get status`.
4. Kontrollera att det finns en backup i HR:s Samba-katalog.
5. Testa också att jobbet fungerar när det Windows-konto som kör jobbet är utloggat.
6. Gör samma kontroll för övriga avdelningar.

En lyckad körning ska dokumenteras med datum, backupdestination och resultat. Ett separat återställningstest behövs för att bekräfta att filerna går att få tillbaka.

## 6. Viktigt att kontrollera

- **Behörigheter:** Kontot som kör jobbet måste kunna läsa källmappen och skriva till rätt Samba-katalog.
- **Diskutrymme:** Ubuntu-backupdisken är 5 GB. Kontrollera ledigt utrymme innan alla jobb aktiveras.
- **Backupversioner:** Windows Server Backup kan skriva över föregående backup vid en ny körning till samma nätverksdestination. Separata avdelningsmappar är inte samma sak som versionshantering.
- **Schema:** Task Scheduler-jobben är separata från det redan befintliga schemat i Windows Server Backup.

## 7. Dokumentation av resultat

| Kontroll | Resultat |
|---|---|
| Kan Windows Server nå Samba-delningen? | Fyll i efter test |
| Kan backupkontot skriva i avdelningsmapparna? | Fyll i efter test |
| Lyckades schemalagd backup? | Fyll i efter test |
| Går en fil att återställa? | Fyll i efter test |

**Källa:** [Microsoft Learn – wbadmin start backup](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/wbadmin-start-backup)
