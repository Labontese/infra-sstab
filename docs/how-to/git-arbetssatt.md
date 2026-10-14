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
