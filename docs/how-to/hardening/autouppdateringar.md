Härdning av Ubuntu genom aktivera säkerhetsuppdateringar

Aktivera säkerhetsuppdateringar på Ubuntu-server (unattended-upgrades).  

1. Installation  
```sudo apt update```
```sudo apt install unattended-upgrades```

2. Aktivering av automatiska uppdateringar,  
```sudo dpkg-reconfigure -plow unattended-upgrades```  
Välj Yes/Ja om du påbjuds bekräftningar.

3. Läs konfigurationsfil  
```sudo nano /etc/apt/apt.conf.d/50unattended-upgrades``` 

4. Verifiera konfigurationsfil
```sudo unattended-upgrade --dry-run --debug``` 