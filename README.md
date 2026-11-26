# infra-sstab

Driftdokumentation för **Skämt & Sido Transport AB**, skoluppgiften Boiler Room. Här dokumenterar teamet nätverket, servrarna, katalogtjänsten (AD DS) och fildelningen.

## Miljön i korthet

| Server | Roll | IP-adress |
|---|---|---|
| SRV-01-DC | Windows Server 2025: AD DS, DNS, DHCP | 192.168.50.10 |
| SRV-02-LNX | Ubuntu Server: backup | 192.168.50.50 |
| FW01 | Brandvägg och gateway | 192.168.50.1 / 192.168.99.1 |
| SW01 | Core-switch | 192.168.99.2 |

AD-domänen heter `sost.local`. Produktionsnätet är `192.168.50.0/24` och managementnätet `192.168.99.0/24`. Fullständig plan finns i [IP-adressplanen](docs/reference/ip-plan.md).

## Dokumentation

Dokumentationen ligger i [docs/](docs/) och är indelad enligt [Diátaxis](https://diataxis.fr/), se [docs/README.md](docs/README.md).

### Tutorials – lär dig genom att göra

| Dokument | Innehåll |
|---|---|
| [001 – Ubuntu Server](docs/tutorials/001.md) | Installation av Ubuntu Server utan grafiskt gränssnitt, statisk IP, nginx och Samba |
| [002 – Windows Server 2025](docs/tutorials/002.md) | Installation, statisk IP/DNS och AD DS som domänkontrollant |
| [Separata backupscheman](docs/tutorials/separata-backupscheman.md) | Ett eget schemalagt backupjobb per avdelning från Windows Server till Samba |

### How-to – lös en specifik uppgift

| Dokument | Innehåll |
|---|---|
| [Git-arbetssätt](docs/how-to/git-arbetssatt.md) | En branch per uppgift, PR med peer review och vanliga git/gh-kommandon |
| [Backup av SRV-01-DC](docs/how-to/how-to-backup-windows-server.md) | Säkerhetskopiera SRV-01-DC till SRV-02-LNX med Windows Server Backup och återställa |
| [Felsök nginx](docs/how-to/felsok-nginx.md) | Status, konfigurationstest, brandvägg och loggar när webbsidan inte går att nå |
| [Startsidan i Edge](docs/how-to/startsida-gpo.md) | GPO som ger klienterna startsidan på SRV-02-LNX i Edge och öppnar den vid inloggning |
| [Härdning: brandvägg UFW](docs/how-to/hardening/ufw.md) | UFW-regler på SRV-02-LNX: SSH från produktionsnätet, SMB3 bara från SRV-01-DC |
| [Härdning: SSH](docs/how-to/hardening/ssh.md) | Inställningar i `sshd_config` mot brute force och obehörig inloggning |
| [Härdning: automatiska säkerhetsuppdateringar](docs/how-to/hardening/autouppdateringar.md) | `unattended-upgrades` på Ubuntu Server |
| [Härdning: Windows-brandväggen](docs/how-to/hardening/windows-brandvagg.md) | Brandväggen på SRV-01-DC: profiler enligt CIS via GPO, regler bara från produktionsnätet |

### Referens – exakta fakta

| Dokument | Innehåll |
|---|---|
| [IP-adressplan](docs/reference/ip-plan.md) | Nät, adressindelning, servrar (CI) och åtkomstregler |
| [Användare och säkerhetsgrupper](docs/reference/OU.md) | OU:er per avdelning, användarkonton och säkerhetsgrupper i AD |
| [Behörighetsmatris](docs/reference/acl/acc-plan.md) | Vilka grupper som får läsa och skriva i vilka mappar |
| [Lösenords- och utlåsningspolicy](docs/reference/losenordspolicy.md) | Default Domain Policy och PSO:er per avdelning enligt CIS Benchmark kapitel 1 |
| [Minsta rättighet](docs/reference/least-privilege.md) | Rättigheter på domänkontrollanten enligt CIS kapitel 2.2 och behörighet per grupp |
| [Fildelning på Windows Server](docs/reference/Fildelning.md) | Mappar och behörigheter för avdelningarnas fildelning enligt least privilege |
| [nginx-sökvägar](docs/reference/nginx-sokvagar.md) | Var nginx har konfiguration, webbfiler och loggar |

### Övrigt

| Dokument | Innehåll |
|---|---|
| [Incident-playbook](docs/incident-playbook.md) | Inte påbörjad |
| [CHANGELOG](CHANGELOG.md) | Vad som har ändrats och när |
| [AI-logg](docs/ai-logg.md) | All AI-användning i projektet, regler för vad som får skickas till AI och mall för nya poster (kursmål 13) |
| [Startsida för nginx](web/index.html) | Sidan som nginx på SRV-02-LNX visar, `/var/www/html/index.html` |

Mallar för nya dokument finns som `MALL.md` i varje mapp under `docs/`.

## Arbeta i repot

Varje uppgift görs i en egen branch från `main`, med namnet `<typ>/<kort-beskrivning>` där typen är `feature/`, `fix/` eller `docs/`. Allt går till `main` via Pull Request med review av någon annan i teamet. Se [Git-arbetssätt](docs/how-to/git-arbetssatt.md).

PR-mallen i [.github/pull_request_template.md](.github/pull_request_template.md) fylls i automatiskt när du skapar en PR på GitHub. Den innehåller en AI-logg där all AI-användning dokumenteras (kursmål 13).

**Team:** Daniel, Jan, Jonas och Liam.
