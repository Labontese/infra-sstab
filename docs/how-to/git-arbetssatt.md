# How-to: Git-arbetssätt i teamet

Kursuppgiften (Kursmål 15) kräver full spårbarhet på allt arbete. Det ställer tre krav på hur vi jobbar i det här repot:

1. Varje uppgift görs i en egen kortlivad branch från `main`.
2. Sammanslagning till `main` sker enbart via Pull Request med genomförd och dokumenterad peer review.
3. Varje persons tekniska bidrag ska tydligt gå att se i Git-historiken.

## 1. En branch per uppgift

Jobba aldrig direkt på `main`. Utgå alltid från senaste `main` och skapa en ny branch för varje uppgift:

```
git switch main
git pull
git switch -c <typ>/<kort-beskrivning>
```

Branchnamnet består av en typ och en kort beskrivning. Typen ska vara samma som prefixet i dina commit-meddelanden:

| Typ | Används för | Commit-prefix | Exempel |
|---|---|---|---|
| `feature/` | Något nytt: ny tjänst, nytt skript, ny konfiguration | `feat:` | `feature/samba-backupshare` |
| `fix/` | Rättar något som är fel | `fix:` | `fix/hardening-ufw-least-privilege` |
| `docs/` | Ny eller ändrad dokumentation | `docs:` | `docs/losenordspolicy-pso` |

Regler för namnet:

- Bara små bokstäver, siffror och bindestreck. Inga mellanslag och inga å, ä, ö.
- Kort men beskrivande: läsaren ska förstå vad branchen gör utan att öppna den.
- Inget personnamn. Vem som gjort arbetet syns redan i commits och PR:en.
- En uppgift per branch. Blir arbetet stort, dela upp det i flera brancher och PR:er.
- Bestäm namnet innan du skapar PR:en. Byter du namn på en branch som har en öppen PR stänger GitHub PR:en.

Pusha branchen till remote så den syns för resten av teamet:

```
git push -u origin <typ>/<kort-beskrivning>
```

De gamla personliga brancherna (`daniel`, `Liam`, `Jonas`, `Jan0321`) används inte för nytt arbete.

## 2. Merge till `main` enbart via PR med peer review

Inga direkta pushar till `main`. När uppgiften är klar, skapa en PR och välj en granskare:

```
git push
gh pr create --base main --reviewer <granskarens-github-namn>
```

En annan teammedlem (inte du själv) ska läsa igenom PR:en och lämna en dokumenterad kommentar/review i GitHub innan den mergas – godkännande eller begärda ändringar ska synas i PR:ens kommentarer, inte bara sägas muntligt. Mergea inte din egen PR utan att detta har skett.

När PR:en är mergad tas branchen bort, både på GitHub och lokalt:

```
gh pr merge <nummer> --delete-branch
git switch main
git pull
git branch -d <typ>/<kort-beskrivning>
```

## 3. Spårbara individuella bidrag

Git-historiken är beviset på vem som gjort vad, så:

- Committa under ditt eget namn/e-post (`git config user.name` / `user.email` – kontrollera med `git log --format='%an %s' -1` att rätt författare visas).
- Skriv commit-meddelanden som beskriver *vad* och *varför*, inte bara "fix" eller "uppdatering".
- Håll commits små och ämnesindelade – en commit per logisk ändring, inte en enda stor commit för hela veckans arbete.
- Undvik att committa i någon annans namn eller att skriva om (`rebase -i`, `commit --amend`) commits som redan är pushade och som andra kan ha byggt vidare på.

Resultatet: vem som helst ska kunna köra `git log --author="<namn>"` eller `gh pr list --state merged --author <github-namn>` och se exakt vilket tekniskt bidrag den personen stått för.

## Bra att ha kommandon

### Komma igång

```
git clone https://github.com/Labontese/infra-sstab.git
cd infra-sstab
git switch -c docs/min-uppgift      # skapa en branch för din första uppgift
```

### Se vad som händer

```
git status                          # vad är ändrat/nytt just nu
git diff                            # exakt vad som ändrats, rad för rad
git log --oneline -10                # senaste 10 commits, kort
git log --author="<namn>"            # bara en persons commits
git branch -a                        # alla branches, lokala + remote
```

### Spara och pusha ditt arbete

```
git add <fil>                        # lägg till en specifik fil (undvik git add . om du inte kollat status först)
git add docs/how-to/git-arbetssatt.md   # exempel: lägg till en specifik fil med filnamn
git commit -m "docs: kort beskrivning av vad och varför"
git push                             # om branchen redan spåras mot remote
git push -u origin <typ>/<kort-beskrivning>   # första gången du pushar branchen
```

### Hämta andras ändringar

```
git fetch origin                     # hämta senaste info om alla branches utan att ändra din
git pull                             # hämta OCH mergea in i din nuvarande branch
git merge origin/main                # dra in senaste main i din branch (gör regelbundet om uppgiften tar flera dagar)
```

### Vid merge-konflikt

1. Git markerar konflikten i filen med `<<<<<<<`, `=======`, `>>>>>>>`.
2. Öppna filen, välj/kombinera vad som ska vara kvar, ta bort markeringarna helt.
3. ```
   git add <filen-du-löste>
   git commit             # slutför mergen, standardmeddelandet räcker oftast
   ```
4. Osäker och vill backa ur hela mergen istället? `git merge --abort` (fungerar bara innan du committat mergen).

### Pull Requests via `gh`

```
gh pr create --base main --reviewer <github-namn>  # skapa PR för din branch med granskare
gh pr list                                       # se alla öppna/stängda PR:er
gh pr view <nummer>                              # läs en specifik PR, inkl. beskrivning
gh pr checkout <nummer>                          # checka ut någon annans PR lokalt för att granska den
gh pr review <nummer> --approve -b "Ser bra ut"  # godkänn efter granskning
gh pr review <nummer> --request-changes -b "..."  # begär ändringar
gh pr merge <nummer> --delete-branch             # mergea och ta bort branchen (bara efter godkänd review, se ovan)
```

### Om du klantar dig

```
git stash                 # gömmer undan oavslutade ändringar tillfälligt (t.ex. innan git switch)
git stash pop              # tar fram dem igen
git restore <fil>          # kasta lokala, osparade ändringar i en fil
git reset --soft HEAD~1    # ångra senaste commit men behåll ändringarna (bara om den INTE är pushad än)
```

**Pusha aldrig `--force` eller gör `reset --hard`/`rebase` på en branch andra redan hämtat, utan att prata med teamet först** – det kan radera eller krocka med deras arbete.
