Härdning av Ubuntu med brandvägg UFW.

Konfigurera brandvägg 'UFW' (Uncomplicated Firewall) på Ubuntu med minsta rättigheter (Least Priv.). 

Blockera all inkommande trafik som standard.  
Enbart släppa igenom nödvändig trafik (SSH och SAMBA). 

```sudo apt update```			
```sudo apt install ufw```		Installera UFW om redan inte installerat

Kontrollera att brandvägg är avstängd innan påbörjad konfiguration:
```sudo ufw status```			Läser status

1. Neka inkommande trafik  
```sudo ufw default deny incoming```

2. Tillåt utgående trafik  
```sudo ufw default allow outgoing```

3. Tillåt endast nödvändig trafik  
```sudo ufw allow ssh```		Tillåter SSH	Port: 22
```sudo ufw allow samba```		Tillåter SAMBA	Port 445/tcp, 139/tcp

Aktivera UFW  
```sudo ufw enable```

Visa brandvägg-status samt standardregler (inkommande/utgående trafik).
```sudo ufw status verbose```