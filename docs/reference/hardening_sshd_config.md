Härdning av SSH-tjänsten i Ubuntu (/etc/ssh/sshd_config)

Skydda Ubuntu-server mot brute force-attacker och obehörig fjärranslutning via SSH.

1. Öppna konfigurationsfil  
```sudo nano /etc/ssh/sshd_config```

2. Ändra värden i fil, spara efteråt.  
```PermitRootLogin no``` förhindrar angripare att logga in som root
```MaxAuthTries 3``` bryter anslutning efter 3 misslyckade försök
```PasswordAuthentication no``` 

3. Starta om SSH-tjänst  
```sudo systemctl restart ssh```

Tips:   
Stäng inte ner Terminalen innan du verifierat att inte bli utelåst ur ditt egna system:  
Starta ny terminal och verifiera att det går att logga in innan du stänger ner.