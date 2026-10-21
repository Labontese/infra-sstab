
## Behörighetsmatris
| Grupp | HR | Ledning | Ekonomi | Lager | IT | Gemensamt |
|---|---|---|---|---|---|---|
| gg-hr | RW | X | X | X | X | R |
| gg-ledning | X | RW | X | X | X | R |
| gg-ekonomi | X | X | RW | RW | X | R |
| gg-lager | X | X | X | RW | X | R |
| gg-it | X | X | X | X | RW | R |
| gg-anstallda | X | X | X | X | X | R |

## SMB Config
### Utkast för samba konfigurering
```
[HR]
   comment = HR - Personal och kanslig
   information
   path = /srv/samba/HR
   browsable = yes
   read only = no
   guest ok = no
   valid users = @gg-hr
   create mask = 0660
   directory mask = 2770

[Ledning]
   comment = Ledning - Foretagsledning
   path = /srv/samba/Ledning
   browsable = yes
   read only = no
   guest ok = no
   valid users = @gg-ledning
   create mask = 0660
   directory mask = 2770

[Ekonomi]
   comment = Ekonomi - Fakturor och budget
   path = /srv/samba/Ekonomi
   browsable = yes
   read only = no
   guest ok = no
   valid users = @gg-ekonomi
   create mask = 0660
   directory mask = 2770

[Lager]
   comment = Lager - Lager och transporter
   path = /srv/samba/Lager
   browsable = yes
   read only = no
   guest ok = no
   valid users = @gg-lager @gg-ekonomi
   create mask = 0660
   directory mask = 2770

[IT]
   comment = IT - System och teknisk drift
   path = /srv/samba/IT
   browsable = yes
   read only = no
   guest ok = no
   valid users = @gg-it
   create mask = 0660
   directory mask = 2770

[Gemensamt]
   comment = Gemensamma dokument
   path = /srv/samba/Gemensamt
   browsable = yes
   read only = yes
   guest ok = no
   valid users = @gg-anstallda
   ```