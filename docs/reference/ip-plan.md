# Referens: IP-adressplan – Skämt & Sido Transport AB

Bolagets nätverk är uppdelat i två separata nät: ett produktionsnät för servrar och klienter, och ett isolerat managementnät för nätverksutrustningens admingränssnitt. Produktionsnätets adressering är redan etablerad i `tutorials/001.md`.

## Nätöversikt

| Nät | Subnät | Gateway | Isolering |
|---|---|---|---|
| Produktion | 192.168.50.0/24 | 192.168.50.1 | Nås av klienter, servrar, DHCP |
| Management | 192.168.99.0/24 | 192.168.99.1 | Isolerat – nås endast från en dedikerad adminklient, aldrig från produktionsnätet |

## Adressindelning – Produktion (192.168.50.0/24)

| Intervall | Syfte |
|---|---|
| 192.168.50.1 | Gateway (FW01) |
| 192.168.50.2 – 192.168.50.99 | Statiska adresser: servrar och nätverksutrustning |
| 192.168.50.100 – 192.168.50.254 | DHCP-pool: klienter |

## Adressindelning – Management (192.168.99.0/24)

| Intervall | Syfte |
|---|---|
| 192.168.99.1 | Gateway (FW01) |
| 192.168.99.2 – 192.168.99.49 | Statiska managementadresser (switch, brandvägg, iDRAC) |
| 192.168.99.50 – 192.168.99.99 | Reserverat för adminklient(er) |

Ingen DHCP i managementnätet – samtliga adresser statiska.

## Tilldelade adresser (Configuration Items)

| CI-ID | Namn | Nät | IP-adress | Roll | Källa |
|---|---|---|---|---|---|
| `FW-01` | FW01 | Produktion / Management | 192.168.50.1 / 192.168.99.1 | Edge-brandvägg & gateway, bryggar produktion ↔ management | — |
| `SW-01` | SW01 | Management | 192.168.99.2 | Core-switch, managementgränssnitt | — |
| `SRV-01` | SRV-01-DC | Produktion | 192.168.50.10 | Active Directory (AD DS), DNS, DHCP | — |
| `SRV-01` | SRV-01-DC (iDRAC) | Management | 192.168.99.10 | Out-of-band hårdvarustyrning (BMC) | — |
| `SRV-02` | SRV-02-LNX | Produktion | 192.168.50.50 | Samba/NFS-fildelning, Web/App | Redan konfigurerad, se `tutorials/001.md` |
| `SRV-02` | SRV-02-LNX (iDRAC) | Management | 192.168.99.20 | Out-of-band hårdvarustyrning (BMC) | — |
| `PWR-01` | UPS01 | – | – | Ingen nätverksadress (lokal strömförsörjning) | — |

## Åtkomstregler mellan näten

| Från | Till | Status |
|---|---|---|
| Produktion | Management | Blockerat |
| Management | Produktion | Blockerat |
| Adminklient (i managementnätet) | Switch-/brandväggsadmin | Tillåtet |

## DNS & DHCP

| Tjänst | Server | Adress |
|---|---|---|
| Primär DNS | SRV-01-DC | 192.168.50.10 |
| DHCP-server | SRV-01-DC | 192.168.50.10 |
| DHCP-pool | Klienter | 192.168.50.100 – 192.168.50.254 |

Uppdatera den här sidan så fort fakta ändras – den blir fel om den inte hålls i synk med verkligheten. Länka hit från `how-to/`- och `tutorials/`-sidor istället för att duplicera värden.
