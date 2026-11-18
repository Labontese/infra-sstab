## Sammanfattning
<!-- Vad ändras och varför? En uppgift per PR. Nämn vilka filer som berörs. -->


## Ändringar
<!-- En rad per ändring. Ange källa när du rättar något: en reference-sida, officiell dokumentation eller eget test. -->

| # | Före | Efter | Varför / källa |
|---|---|---|---|
| 1 |  |  |  |

## Öppna frågor till granskaren
<!-- Saker du har sett men inte ändrat. Tagga personen, t.ex. @lehtela. Ta bort avsnittet om det inte behövs. -->

- 

## Testplan
<!-- Skriv kommando och förväntat resultat. [x] = gjort, [ ] = måste göras innan merge. -->

- [ ] 

## AI-logg (kursmål 13)
<!-- Fyll i om AI har använts i den här PR:en. Annars, skriv bara: "Ingen AI användes."
     Lägg också till en rad i docs/ai-logg.md med länk till den här PR:en. -->
1. **Användningsfall / Syfte:** <!-- t.ex. felsökning, granskning av dokumentation, konfiguration -->
2. **Verktyg & Modell:** <!-- t.ex. Claude Code (Claude Opus 5.5), ChatGPT (GPT-5), GitHub Copilot -->
3. **Prompt / Metod:** <!-- Vilken prompt eller arbetsmetod gav bäst resultat? -->
4. **Data som matats in:** <!-- Vad skickades till AI:n? -->
   - [ ] Inga hemligheter (lösenord, API-nycklar, privata SSH-nycklar, åtkomsttokens)
   - [ ] Inga personuppgifter eller riktiga kunddata
   - [ ] Interna uppgifter (IP-adresser, kontonamn, arkitektur) är anonymiserade eller bedömda som okej att dela
5. **Resultat & Värde:** <!-- Hur mycket tid sparades? Blev kvaliteten högre? -->
6. **Begränsningar & Lärdomar:** <!-- Var hade AI:n fel? Vad krävde manuell korrigering? -->
   - **Verifiering:** <!-- Hur kontrollerade du AI:ns förslag: eget test, officiell dokumentation, reference-sida? -->
   - **Avvikelser:** <!-- Förslag som inte stämde med ditt eget testresultat, och vad du gjorde i stället. Skriv "Inga" om allt stämde. -->

## Checklista innan granskning
- [ ] Branchen heter `<typ>/<kort-beskrivning>` (`feature/`, `fix/` eller `docs/`)
- [ ] Commit-meddelandena börjar med samma typ (`feat:`, `fix:` eller `docs:`)
- [ ] Granskare är vald, och det är inte jag själv
- [ ] Ny dokumentation följer mallen i rätt Diátaxis-mapp (`docs/<mapp>/MALL.md`)
- [ ] Värden som IP-adresser länkas till `reference/` i stället för att upprepas
