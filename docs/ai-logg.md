# AI-logg

Gemensam logg över hur teamet använder AI i projektet (kursmål 13). Målet är att AI:ns förslag alltid verifieras mot eget testresultat eller officiell dokumentation, och att vi skriver ner när förslagen avviker.

## Så här loggar du

| Situation | Gör så här |
|---|---|
| AI användes i en PR | Fyll i AI-loggen i PR-mallen och lägg till **en rad** i översikten nedan med länk till PR:en |
| AI användes utan PR (felsökning på en VM, frågor under labben) | Lägg till en rad i översikten **och** en post under "Poster" med [mallen](#mall) |
| Tidigare användning som inte är loggad | Gå igenom dina gamla promptar och lägg till dem på samma sätt, med det datum de gjordes |

## Vad får skickas till AI?

Bedöm alltid informationen innan du skickar den.

| Bedömning | Exempel |
|---|---|
| **Kan skickas** | Allmänna frågor ("vad gör en routetabell?"), utdrag ur offentlig leverantörsdokumentation, avidentifierade felbeskrivningar utan hemligheter, repots egen dokumentation om labbmiljön |
| **Anonymisera eller rensa först** | Konfigurationsfiler med interna IP-adresser, resursnamn eller kontonamn, loggrader med användar-ID eller IP-adresser, opublicerad nätverksarkitektur, skärmdumpar av adminverktyg |
| **Skicka inte** | Lösenord, API-nycklar, privata SSH-nycklar, åtkomsttokens, DSRM-lösenord, skärmdumpar med synliga inloggningsuppgifter, personuppgifter och riktiga kunddata |

Labbmiljön för Skämt & Sido Transport AB är fiktiv. Dess interna IP-adresser och kontonamn räknas därför som okej att dela, men lösenord delas aldrig.

## Översikt

| Datum | Vem | Syfte | Verktyg | Dokumenterat i | Avvikelse? |
|---|---|---|---|---|---|
| 2026-10-21 | Daniel | Rita roller, behörigheter och mappstruktur som Excalidraw, och ta fram en Samba-konfiguration för behörighetsmatrisen | Claude Code (Claude Sonnet 5) | Lokala filer, inte i repot | Nej |
| 2026-11-18 | Daniel | Granska och rätta `tutorials/001.md` | Claude Code (Claude Opus 5.5) | #25 | Ja, se [posten nedan](#2026-11-18--daniel--granskning-av-001md-och-hardening_ufwmd) |
| 2026-11-18 | Daniel | Least privilege-regler i `hardening_ufw.md` | Claude Code (Claude Opus 5.5) | #27 | Ja, se [posten nedan](#2026-11-18--daniel--granskning-av-001md-och-hardening_ufwmd) |
| 2026-11-18 | Daniel | Branch per uppgift i `git-arbetssatt.md` | Claude Code (Claude Opus 5.5) | #28 | Ja, namnbyte stängde #26 |
| 2026-11-18 | Daniel | PR-mall med AI-logg | Claude Code (Claude Opus 5.5) | #29 | Nej |
| 2026-11-18 | Daniel | Uppdatera README | Claude Code (Claude Opus 5.5) | #30 | Nej |
| 2026-11-18 | Daniel | Flytta härdningsfilerna enligt #31 | Claude Code (Claude Opus 5.5) | #33 | Nej |
| 2026-11-18 | Daniel | Review av #32, #34 och #35 och issues om backup (#36–#41) | Claude Code (Claude Opus 5.5) | Review-kommentarerna och issuerna | Nej |
| 2026-11-18 | Liam | Förbättra how-to-backup-windows-server.md (backup per avdelning till Samba) och ta fram färdiga kommandon | Claude (claude.ai, Claude Sonnet 5.5) | #35 | Ja, två förslag togs bort, se posten nedan |
| 2026-11-19 | Daniel | Granska och godkänna #35 | Claude Code (Claude Opus 5.5) | Granskningen på #35 | Nej |
| 2026-11-19 | Daniel | Logga AI-användning i AI-loggen och beskriva reglerna i README | Claude Code (Claude Opus 5.5) | #44 | Nej |
| 2026-11-19 | Daniel | Hitta alla stavningar av gruppen för alla anställda och rätta `least-privilege.md` efter beslutet i #43 | Claude Code (Claude Opus 5.5) | #45 | Nej |
| 2026-11-23 | Jonas | Strukturera om driftsättningsguide Windows Server 2025 (002.md), rensa dubbletter och lägga till avslutning | Google Antigravity (Gemini / Claude Sonnet) | #32 | Nej |
| 2026-11-23 | Jonas | Granska och uppdatera arkiveringsskript för Samba-backup (`arkivera-backup.sh`) | Google Antigravity (Claude Sonnet) | #46 | Nej |
| 2026-11-23 | Daniel | Granska arkivskriptet i #46 och ta fram ett testat förslag till rättning | Claude Code (Claude Opus 5.5), Codex CLI (gpt-6.1-terra) | Granskningen och kommentaren på #46 | Ja, se [posten nedan](#2026-11-23--daniel--granskning-av-arkivskriptet-i-46) |
| 2026-11-23 | Daniel | Härda Windows-brandväggen på SRV-01-DC enligt CIS avsnitt 9, testa i labbet och skriva guiden | Claude Code (Claude Opus 5.5), Codex CLI (gpt-6.1-terra) | #58 | Ja: NetBIOS 137–139 rättat till 139, loggmappen saknades, Modify i stället för FullControl |
| 2026-11-24 | Daniel | Skriva klart den avklippta raden i backupguiden | Claude Code (Claude Opus 5.5) | #61 | Ja: en kort hänvisning till #36 blev ingen länk och ersattes med en hel länk |
| 2026-11-25 | Liam | Skapat mall för DHCP Återställning som sedan skrevs i manuellt| Claude Sonnet 5| #39 | Nej |
| 2026-11-25 | Liam | Skapat mall för backup rutinen som sedan skrevs i manuellt| Claude Sonnet 5| #53 | Nej |
| 2026-11-25 | Daniel | Granska och godkänna #60, #62, #63 och #68 | Claude Code (Claude Opus 5.5) | Granskningarna | Nej |
| 2026-11-25 | Daniel | Startsida för nginx på SRV-02-LNX | Claude Code (Claude Opus 5.5) | #65 | Ja: rubriken kunde inte radbrytas på smala skärmar |
| 2026-11-25 | Daniel | Skript för AD, fildelning, minsta rättighet och lösenordspolicy ur labbskripten | Claude Code (Claude Opus 5.5) | #70 | Ja: medlemskapet i `gg-anstallda` rättat efter `OU.md` |
| 2026-11-25 | Daniel | Bygga en Windows 11-klient i testmiljön och testa brandväggen från den | Claude Code (Claude Opus 5.5) | #72 | Ja: svarsfilen hade tre fel (språk, för långt kommando, OpenSSH utan internet), och kontrollen av gästagenten använde ett kommando som inte finns |
| 2026-11-26 | Daniel | GPO som ger klienterna startsidan i Edge, testad med en ny inloggning på klienten | Claude Code (Claude Opus 5.5) | #73 | Ja: Edges bakgrundsstart tog över inloggningen, och Run-posten via Preferences blev kvar på klienten. Bytt till en policy |

## Mall

Kopiera blocket, lägg det under "Poster" och fyll i.

```markdown
### ÅÅÅÅ-MM-DD – Namn – Kort rubrik

1. **Användningsfall / Syfte:** t.ex. felsökning, konfiguration, granskning av dokumentation
2. **Verktyg & Modell:** t.ex. Claude Code (Claude Opus 5.5), ChatGPT (GPT-5), GitHub Copilot
3. **Prompt / Metod:** vilken prompt eller arbetsmetod gav bäst resultat?
4. **Data som matats in:** vad skickades till AI:n?
   - [ ] Inga hemligheter (lösenord, API-nycklar, privata SSH-nycklar, åtkomsttokens)
   - [ ] Inga personuppgifter eller riktiga kunddata
   - [ ] Interna uppgifter (IP-adresser, kontonamn, arkitektur) är anonymiserade eller bedömda som okej att dela
5. **Resultat & Värde:** hur mycket tid sparades? Blev kvaliteten högre?
6. **Begränsningar & Lärdomar:** var hade AI:n fel? Vad krävde manuell korrigering?
   - **Verifiering:** hur kontrollerade du förslaget: eget test, officiell dokumentation, reference-sida?
   - **Avvikelser:** förslag som inte stämde med ditt eget testresultat, och vad du gjorde i stället. Skriv "Inga" om allt stämde.
```

## Poster

### 2026-11-18 – Daniel – Granskning av 001.md och hardening_ufw.md

1. **Användningsfall / Syfte:** Hitta och rätta fel i befintlig dokumentation, en fil i taget, med egen PR per fil
2. **Verktyg & Modell:** Claude Code (Claude Opus 5.5)
3. **Prompt / Metod:** "Ta en fil, hitta fel och förbättra den". Det fungerade bäst när AI:n fick korskolla mot repots egna referenssidor (`ip-plan.md`, backup-guiden) i stället för att svara ur minnet
4. **Data som matats in:** Repots egen dokumentation och skärmdumpar från installationen
   - [x] Inga hemligheter (lösenord, API-nycklar, privata SSH-nycklar, åtkomsttokens)
   - [x] Inga personuppgifter eller riktiga kunddata
   - [x] Interna uppgifter (IP-adresser, kontonamn, arkitektur) är anonymiserade eller bedömda som okej att dela
5. **Resultat & Värde:** Tolv fel i 001.md och sju i hardening_ufw.md hittades på några minuter. Flera hade fått installationen att misslyckas: TAB i YAML, fel tjänstnamn (`samba` i stället för `smbd`) och `ufw allow samba` som inte fungerar
6. **Begränsningar & Lärdomar:**
   - **Verifiering:** YAML kontrollerat med `yaml.safe_load`. Länkar kontrollerade med skript. Server- eller Desktop-frågan avgjordes av författaren (Jonas), inte av AI:n
   - **Avvikelser:** AI:n föreslog först att port 80 skulle öppnas för nginx på SRV-02. När den läste `ip-plan.md` visade det sig att SRV-02 bara är backupserver, så förslaget övergavs. AI:n trodde också att en öppen PR följer med när head-branchen byter namn. Det gjorde den inte, och #26 stängdes och fick ersättas av #27. Lärdomen står nu i `git-arbetssatt.md`

### 2026-11-18 – Liam – Förbättring av backupguide per avdelning

1. **Användningsfall / Syfte:** Granska och förbättra guiden för separata backupjobb per avdelning (Task Scheduler + `wbadmin start backup` mot en Samba-delning på Ubuntu) och ta fram färdiga kommandon, test- och återställningssteg och felsökning. Hjälp med git-flödet inför PR:en (merge i vim) ingick som sidoärende
2. **Verktyg & Modell:** Claude (claude.ai, Claude Sonnet 5.5)
3. **Prompt / Metod:** Hela den ursprungliga guiden och lektionstexten klistrades in med uppdraget att förbättra guiden och ge färdiga kommandon inför en PR. AI:n kontrollerade kommandosyntaxen mot Microsoft Learn i stället för att svara ur minnet, och det avslöjade att dokumentationen beskriver `-user`/`-password` för backup till fjärrmapp medan originalguiden använde `cmdkey`. Guiden ändrades därefter i omgångar
4. **Data som matats in:** Guidetexten med mappstruktur, avdelningsnamn, den interna IP-adressen `192.168.50.50` och kontonamnet `backupuser`, samt lektionstexten
   - [x] Inga hemligheter (lösenord, API-nycklar, privata SSH-nycklar, åtkomsttokens)
   - [x] Inga personuppgifter eller riktiga kunddata
   - [x] Interna uppgifter (IP-adresser, kontonamn, arkitektur) är anonymiserade eller bedömda som okej att dela
5. **Resultat & Värde:** Guiden fick färdiga kommandon för alla sex avdelningar, kontroll av nätverk och funktion, test- och återställningssteg, en felsökningstabell och en säkerhetsnotering om att backuperna blir läsbara för alla med åtkomst till delningen. AI:n flaggade också att `cmdkey` kanske inte fungerar i schemalagda jobb. Tidsbesparingen är inte uppmätt
6. **Begränsningar & Lärdomar:**
   - **Verifiering:** Syntaxen kontrollerades mot Microsoft Learn (`-include` med mappar, `-vssCopy`, att `enable backup` påverkar det dagliga schemat och att en ny backup till samma fjärrmapp skriver över den förra). AI:n kan inte köra kommandon i vår miljö, och guiden är ännu inte körd på servern: `cmdkey` i ett schemalagt jobb, körning med utloggat konto och återställningskommandot är otestade (Uppdate: testat i efterhand)

   - **Avvikelser:** Inga testavvikelser hittills, eftersom inget är testat på servern. Två AI-förslag valdes bort: ett PowerShell-skript som skapar alla sex jobb (jobben skapas i stället manuellt i Task Scheduler med färdiga argument) och en mätning av mapparnas storlek mot backupdiskens storlek (ersatt av en valfri kontroll av ledigt utrymme med `df -h`). Om `cmdkey` visar sig inte fungera i det schemalagda jobbet läggs det till här, tillsammans med vad som användes i stället 

### 2026-11-23 – Daniel – Granskning av arkivskriptet i #46

1. **Användningsfall / Syfte:** Granska Jonas arkivskript i #46 (issue #37) och ta fram ett rättat förslag som går att ta in med "Commit suggestion"
2. **Verktyg & Modell:** Claude Code (Claude Opus 5.5) för granskning, tester och förslag. Codex CLI (gpt-6.1-terra) för en oberoende granskning av förslaget
3. **Prompt / Metod:** Claude Code körde originalet och förslaget i ett påhittat träd i WSL och mätte arkivets storlek i labbet utan att skriva något där. Förslaget skickades till Codex tills det inte gav några fynd, och varje fynd prövades med ett test innan det rättades eller avvisades. Reviewen visades för Daniel innan den skickades
4. **Data som matats in:** Repots skript och how-to-guide, sökvägar och IP-adresser från labbmiljön
   - [x] Inga hemligheter (lösenord, API-nycklar, privata SSH-nycklar, åtkomsttokens)
   - [x] Inga personuppgifter eller riktiga kunddata
   - [x] Interna uppgifter (IP-adresser, kontonamn, arkitektur) är anonymiserade eller bedömda som okej att dela
5. **Resultat & Värde:** Sex fel i originalet, alla bekräftade med test. Bland annat avslutades skriptet med kod 0 och lämnade ett trasigt arkiv när `tar` misslyckades. Mätningen visade att backupen på 14 GB blir 6,9 GB som `tar.gz`, så 30 dagars arkiv fyller en disk på 98 GB efter cirka 12 dagar. Förslaget godkändes i 19 testfall
6. **Begränsningar & Lärdomar:**
   - **Verifiering:** Funktionstester i WSL, shellcheck i VS Code, mätning och test av filrättigheter i labbet
   - **Avvikelser:** Codex hittade fel i Claude Codes förslag i två av tre granskningar, till exempel att ett avbrott kunde lämna ett trasigt arkiv under rätt namn. Claude Code skrev i reviewen att `chmod 400` inte skyddar mot ransomware, medan en annan AI påstod motsatsen. Ett test i labbet visade att båda var för kategoriska: `chmod 400` stoppar konton som varken äger filen eller är root, men inte root eller ägaren. Förtydligandet lades som kommentar på #46
