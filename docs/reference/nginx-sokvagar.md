# Referens: nginx-sökvägar på SRV-02-LNX

En referens beskriver fakta – exakt, neutralt, utan resonemang eller instruktioner. Tabeller och listor, inte prosa.

| Sökväg | Innehåll |
|---|---|
| `/var/www/html` | Webbplatsens filer (standardsidan) |
| `/etc/nginx/` | nginx-konfiguration |
| `/etc/nginx/sites-available/` | Konfiguration per webbplats |
| `/etc/nginx/sites-enabled/` | Aktiverade webbplatser (länkar till `sites-available/`) |
| `/var/log/nginx/access.log` | Logg över trafik |
| `/var/log/nginx/error.log` | Felmeddelanden och felsökningsinformation |

Uppdatera den här sidan så fort fakta ändras – den blir fel om den inte hålls i synk med verkligheten. Länka hit från `how-to/`- och `tutorials/`-sidor istället för att duplicera värden.
