# How-to: Felsök nginx när sidan inte går att nå

En how-to-guide löser en konkret uppgift för en läsare som redan vet vad den vill göra – rakt på sak, inga omvägar via grundkoncept.

**Förutsättningar:** nginx är installerat enligt [tutorials/001.md](../tutorials/001.md) och du har sudo-rättigheter på servern.

## Kontrollera att nginx körs

```
sudo systemctl status nginx
```

Står det inte `active (running)`, starta om och kontrollera konfigurationen:

```
sudo nginx -t
sudo systemctl restart nginx
```

`nginx -t` visar vilken fil och rad som är fel om konfigurationen inte går att läsa.

## Kontrollera brandväggen

```
sudo ufw status
```

Om UFW är aktivt och HTTP saknas i listan blockeras sidan. Öppna port 80 (HTTP):

```
sudo ufw allow 'Nginx HTTP'
```

Ska HTTPS också användas, öppna port 80 och 443:

```
sudo ufw allow 'Nginx Full'
```

## Läs loggarna

```
sudo tail -n 50 /var/log/nginx/error.log
sudo tail -n 50 /var/log/nginx/access.log
```

Syns inga anrop i `access.log` når trafiken aldrig fram till nginx – kontrollera nätverk och brandvägg. Syns anropen men med felkoder, läs `error.log`.

Sökvägar till konfiguration, webbfiler och loggar finns i [nginx-sökvägar](../reference/nginx-sokvagar.md).
