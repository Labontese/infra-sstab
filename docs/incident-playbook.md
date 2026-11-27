# Incident-playbook

Vad IT gör när något går fel i Skämt & Sido Transports miljö: vem som gör vad, i vilken ordning och var det dokumenteras. Sidan länkar till guiderna i stället för att upprepa dem.

## Roller

| Roll | Vem | Ansvar |
|---|---|---|
| Anställda | Alla | Rapporterar till IT när något inte fungerar eller verkar konstigt, till exempel filer som inte går att öppna eller ett konto som har låsts |
| IT | `gg-it` | Tar emot rapporten, bedömer, begränsar skadan, åtgärdar och skriver i [incidentloggen](#incidentlogg). Använder sitt adminkonto (`adm-<namn>`) bara för arbetet på servrarna |
| Ledningen | `gg-ledning` | Informeras direkt vid intrång, ransomware eller en server som är nere. Beslutar om polisanmälan och anmälan till IMY |

## Så hanteras en incident

1. **Rapportera.** Den som upptäcker felet kontaktar IT och berättar vad som hände och när.
2. **Bedöm.** IT tar reda på vad som är drabbat: en användare, en tjänst eller en hel server. Gäller det intrång, ransomware eller en server som är nere informeras ledningen direkt.
3. **Begränsa.** Stoppa spridningen innan något återställs. Koppla bort en drabbad dator från nätverket och byt lösenord på konton som kan vara kapade.
4. **Åtgärda och återställ.** Följ scenariot nedan. Kontrollera först att backupen finns, och återställ till en separat mapp innan något skrivs över.
5. **Verifiera.** Kontrollera att tjänsten fungerar för användarna och att återställda filer är hela och går att öppna.
6. **Dokumentera.** Skriv en post i [incidentloggen](#incidentlogg) med faktisk RTO och RPO och vad som ska göras annorlunda.

## Återställningsmål

| Mål | Värde |
|---|---|
| RPO | Högst ett dygn. Backupen tas varje natt kl. 03:00, så ändringar sedan dess kan gå förlorade ([Backup av SRV-01-DC](how-to/how-to-backup-windows-server.md)) |
| RTO för en mapp | 25 sekunder, uppmätt vid återställningsprovet 2026-11-11 |
| RTO för en hel server | Inget mål är satt. Återställning av AD är inte provad ([#36](https://github.com/Labontese/infra-sstab/issues/36)) |

## Ett konto är utlåst

Ett konto låses efter 5 felaktiga lösenord och låses upp av sig självt efter 30 minuter ([lösenordspolicyn](reference/losenordspolicy.md)). IT kan låsa upp det tidigare.

Kör i PowerShell på SRV-01-DC, inloggad med adminkontot.

1. Se vilka konton som är låsta:

   ```powershell
   Search-ADAccount -LockedOut | Select-Object Name, SamAccountName
   ```

2. Kontrollera att det är rätt person som hör av sig, till exempel genom att ringa tillbaka, innan kontot låses upp eller lösenordet byts.
3. Lås upp kontot:

   ```powershell
   Unlock-ADAccount -Identity <konto>
   ```

4. Har användaren glömt lösenordet: sätt ett tillfälligt lösenord och tvinga fram ett byte vid nästa inloggning. PowerShell frågar efter det nya lösenordet:

   ```powershell
   Set-ADAccountPassword -Identity <konto> -Reset
   Set-ADUser -Identity <konto> -ChangePasswordAtLogon $true
   ```

Låses flera konton samtidigt kan någon försöka gissa lösenord. Hantera det som ett [misstänkt intrång](#misstänkt-intrång-eller-ransomware).

## Misstänkt intrång eller ransomware

Tecken: filer som inte går att öppna eller har fått nya filändelser, ett meddelande om lösensumma, många låsta konton eller inloggningar som ingen känner igen.

1. **Isolera.** Koppla bort den drabbade datorn från nätverket direkt: dra ur nätverkskabeln eller stäng av wifi. Stäng inte av datorn, så att det går att se vad som har hänt.
2. **Informera** ledningen.
3. **Skydda backupen.** WSB skriver över backupen på SRV-02-LNX varje natt kl. 03:00, så nästa backup kan innehålla krypterade filer. Arkiven i `/srv/samba/arkiv` på SRV-02-LNX delas inte ut och kan inte ändras från Windows, men de sparas bara i några dagar. Leta upp det senaste arkivet från före angreppet och kopiera det till en extern disk:

   ```bash
   sudo ls -la /srv/samba/arkiv/
   ```

4. **Byt lösenord** på konton som kan vara kapade, även adminkonton. Lösenordet för `backupuser` måste i så fall bytas både i AD och i Samba, och backupschemat sättas upp igen ([Backup av SRV-01-DC](how-to/how-to-backup-windows-server.md), avsnitt 2 och 3).
5. **Ta reda på omfattningen:** vilka mappar som är drabbade och sedan när. Loggar att börja i:

   | Server | Logg |
   |---|---|
   | SRV-01-DC | Event Viewer → Windows Logs → Security |
   | SRV-01-DC | Brandväggens logg `C:\Windows\System32\logfiles\firewall\domainfw.log` ([Windows-brandväggen](how-to/hardening/windows-brandvagg.md)) |
   | SRV-02-LNX | Inloggningar över SSH: `sudo journalctl -u ssh` |

6. **Återställ** de drabbade filerna enligt [En fil eller mapp har raderats](#en-fil-eller-mapp-har-raderats), från en version från före angreppet. Öppna några filer i testmappen och kontrollera att de inte är krypterade innan något kopieras tillbaka. En smittad dator installeras om i stället för att städas.
7. **Anmäl.** Ledningen beslutar om polisanmälan. Kan personuppgifter ha kommit ut ska det anmälas till IMY inom 72 timmar.

## SRV-01-DC är nere

Märks på att ingen kan logga in på en ny dator, att mapparna och namnen i nätet inte går att nå (DNS) och att nya datorer inte får någon IP-adress (DHCP).

1. Kontrollera strömmen och UPS01.
2. Öppna serverns konsol via iDRAC från adminklienten i managementnätet: `https://192.168.99.10` ([IP-planen](reference/ip-plan.md)). Där syns om servern startar och vilka fel som visas.
3. Startar Windows men en tjänst är nere: starta om den och läs felet i Event Viewer → Windows Logs → System.

   ```powershell
   Restart-Service DNS
   Restart-Service DHCPServer
   ```

4. Är DHCP-databasen förstörd: följ [Återställa DHCP](how-to/how-to-backup-windows-server.md#5-återställa-dhcp).
5. Startar inte Windows måste servern återställas från backupen. Det är inte provat ännu ([#36](https://github.com/Labontese/infra-sstab/issues/36)).

## SRV-02-LNX är nere

Märks på att nattens backup misslyckas och att startsidan inte går att nå. Ingen förlorar åtkomst till sina filer, eftersom de ligger på SRV-01-DC.

1. Öppna serverns konsol via iDRAC från adminklienten: `https://192.168.99.20`.
2. När servern är igång, kontrollera tjänsterna och disken:

   ```bash
   systemctl status smbd nginx
   df -h /srv/samba
   ```

3. Kör backupen manuellt enligt [Vid misslyckad backup](how-to/rutin-backup.md#vid-misslyckad-backup).
4. Måste servern installeras om: följ [Tutorial 001](tutorials/001.md), avsnitt 2 i [Backup av SRV-01-DC](how-to/how-to-backup-windows-server.md) och [UFW](how-to/hardening/ufw.md). Konfigurationen säkerhetskopieras inte ännu ([#52](https://github.com/Labontese/infra-sstab/issues/52)).

## En fil eller mapp har raderats

Kör i PowerShell på SRV-01-DC, inloggad med adminkontot.

1. Se vilka versioner som finns. Versionen anges i UTC:

   ```powershell
   wbadmin get versions -backupTarget:\\192.168.50.50\backups
   ```

2. Återställ till en separat mapp, inte till originalet. `-recursive` behövs bara för en mapp. WSB frågar efter lösenordet för `backupuser`:

   ```powershell
   New-Item -ItemType Directory -Path C:\Aterstallningstest -Force
   wbadmin start recovery -version:<version> -itemType:File `
       -items:"C:\Fildelning\<avdelning>\<fil eller mapp>" -recursive `
       -backupTarget:\\192.168.50.50\backups -user:backupuser@sost.local `
       -recoveryTarget:C:\Aterstallningstest -quiet
   ```

3. Gå igenom filerna i `C:\Aterstallningstest` tillsammans med användaren: att det är rätt version och att de går att öppna.
4. Kopiera dem till rätt mapp i `C:\Fildelning`, så får de mappens behörigheter. Ta sedan bort `C:\Aterstallningstest`.

## Backupen har misslyckats

Följ [Vid misslyckad backup](how-to/rutin-backup.md#vid-misslyckad-backup) och skriv en post i [incidentloggen](#incidentlogg).

## Kända luckor

| Lucka | Risk | Ärende |
|---|---|---|
| Ingen kopia av backupen utanför SRV-02-LNX | Går SRV-02-LNX sönder försvinner alla backuper. 3-2-1-regeln uppfylls inte | [#38](https://github.com/Labontese/infra-sstab/issues/38) |
| Återställning av AD (System State) är inte provad | Det är inte känt om och hur snabbt SRV-01-DC kan återställas | [#36](https://github.com/Labontese/infra-sstab/issues/36) |
| Konfigurationen på SRV-02-LNX säkerhetskopieras inte | Servern måste byggas upp igen för hand | [#52](https://github.com/Labontese/infra-sstab/issues/52) |
| Återställning från ett arkiv i `/srv/samba/arkiv` är inte provad | Det är inte känt hur lång tid det tar att läsa in ett äldre arkiv | – |

## Incidentlogg

Varje incident får en post här, den senaste överst. Tekniska detaljer om felsökningen skrivs i felsökningsloggen.

```markdown
### ÅÅÅÅ-MM-DD – Kort rubrik

- **Upptäckt:** när och av vem
- **Påverkan:** vilka användare och tjänster, och hur länge
- **Åtgärd:** vad som gjordes
- **Faktisk RTO:** tid från upptäckt till att allt fungerade igen
- **Faktisk RPO:** hur mycket data som gick förlorad, till exempel "ändringar sedan kl. 03:00"
- **Ansvarig:** vem i IT
- **Lärdom:** vad som ska göras annorlunda
```

Inga incidenter är loggade ännu.
