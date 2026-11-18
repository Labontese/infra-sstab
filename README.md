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
| [001 – Ubuntu Server](docs/tutorials/001.md) | Installation av Ubuntu Server, nätverk, nginx och Samba |
| [002 – Windows Server 2025](docs/tutorials/002.md) | Installation, statisk IP/DNS och AD DS som domänkontrollant |

### How-to – lös en specifik uppgift

| Dokument | Innehåll |
|---|---|
| [Git-arbetssätt](docs/how-to/git-arbetssatt.md) | Feature-branches, PR med peer review och vanliga git/gh-kommandon |

### Referens – exakta fakta

| Dokument | Innehåll |
|---|---|
| [IP-adressplan](docs/reference/ip-plan.md) | Nät, adressindelning, servrar (CI) och åtkomstregler |
| [Användare och säkerhetsgrupper](docs/reference/OU.md) | OU:er per avdelning, användarkonton och säkerhetsgrupper i AD |
| [Behörighetsmatris](docs/reference/acl/acc-plan.md) | Vilka grupper som får läsa och skriva i vilka mappar |
| [Lösenords- och utlåsningspolicy](docs/reference/losenordspolicy.md) | Default Domain Policy och PSO:er per avdelning enligt CIS Benchmark kapitel 1 |
| [Minsta rättighet](docs/reference/least-privilege.md) | Rättigheter på domänkontrollanten enligt CIS kapitel 2.2 och behörighet per grupp |

### Övrigt

| Dokument | Innehåll |
|---|---|
| [Incident-playbook](docs/incident-playbook.md) | Inte påbörjad |
| [CHANGELOG](CHANGELOG.md) | Vad som har ändrats och när |

Mallar för nya dokument finns som `MALL.md` i varje mapp under `docs/`.

## Arbeta i repot

Varje person jobbar i en egen branch, och allt går till `main` via Pull Request med review av någon annan i teamet. Se [Git-arbetssätt](docs/how-to/git-arbetssatt.md).

**Team:** Daniel, Jan, Jonas och Liam.
