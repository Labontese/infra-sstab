# How-to: Git-arbetssätt i teamet

Kursuppgiften (Kursmål 15) kräver full spårbarhet på allt arbete. Det ställer tre krav på hur vi jobbar i det här repot:

1. Varje teammedlem arbetar i en egen feature-branch.
2. Sammanslagning till `main` sker enbart via Pull Request med genomförd och dokumenterad peer review.
3. Varje persons tekniska bidrag ska tydligt gå att se i Git-historiken.

## 1. Egen feature-branch per person

Jobba aldrig direkt på `main`. Skapa en branch med ditt namn (eller ett ämne om du vill dela upp ditt eget arbete ytterligare):

```
git switch -c <ditt-namn>
```

Exempel i det här repot: `daniel`, `Liam`, `Jonas`. Pusha branchen till remote så den syns för resten av teamet:

```
git push -u origin <ditt-namn>
```

## 2. Merge till `main` enbart via PR med peer review

Inga direkta pushar till `main`. När din del är klar:

```
git push
gh pr create --base main --head <ditt-namn>
```

En annan teammedlem (inte du själv) ska läsa igenom PR:en och lämna en dokumenterad kommentar/review i GitHub innan den mergas – godkännande eller begärda ändringar ska synas i PR:ens kommentarer, inte bara sägas muntligt. Mergea inte din egen PR utan att detta har skett.

## 3. Spårbara individuella bidrag

Git-historiken är beviset på vem som gjort vad, så:

- Committa under ditt eget namn/e-post (`git config user.name` / `user.email` – kontrollera med `git log --oneline -1` att rätt författare visas).
- Skriv commit-meddelanden som beskriver *vad* och *varför*, inte bara "fix" eller "uppdatering".
- Håll commits små och ämnesindelade – en commit per logisk ändring, inte en enda stor commit för hela veckans arbete.
- Undvik att committa i någon annans namn eller att skriva om (`rebase -i`, `commit --amend`) commits som redan är pushade och som andra kan ha byggt vidare på.

Resultatet: vem som helst ska kunna köra `git log --author="<namn>"` eller titta på en PR och se exakt vilket tekniskt bidrag den personen stått för.

## Bra att ha kommandon

### Komma igång

```
git clone https://github.com/Labontese/infra-sstab.git
cd infra-sstab
git switch <ditt-namn>              # byt till din branch (om den redan finns på remote)
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
git push -u origin <ditt-namn>       # första gången du pushar branchen
```

### Hämta andras ändringar

```
git fetch origin                     # hämta senaste info om alla branches utan att ändra din
git pull                             # hämta OCH mergea in i din nuvarande branch
git merge main                       # dra in senaste main i din feature-branch (gör regelbundet, inte bara vid PR)
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
gh pr create --base main --head <ditt-namn>     # skapa PR för din branch
gh pr list                                       # se alla öppna/stängda PR:er
gh pr view <nummer>                              # läs en specifik PR, inkl. beskrivning
gh pr checkout <nummer>                          # checka ut någon annans PR lokalt för att granska den
gh pr review <nummer> --approve -b "Ser bra ut"  # godkänn efter granskning
gh pr review <nummer> --request-changes -b "..."  # begär ändringar
gh pr merge <nummer>                             # mergea (bara efter godkänd review, se ovan)
```

### Om du klantar dig

```
git stash                 # gömmer undan oavslutade ändringar tillfälligt (t.ex. innan git switch)
git stash pop              # tar fram dem igen
git restore <fil>          # kasta lokala, osparade ändringar i en fil
git reset --soft HEAD~1    # ångra senaste commit men behåll ändringarna (bara om den INTE är pushad än)
```

**Pusha aldrig `--force` eller gör `reset --hard`/`rebase` på en branch andra redan hämtat, utan att prata med teamet först** – det kan radera eller krocka med deras arbete.
