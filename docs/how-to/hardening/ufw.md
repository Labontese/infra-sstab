# Härdning: brandvägg UFW på SRV-02-LNX

Konfigurera brandväggen UFW (Uncomplicated Firewall) på SRV-02-LNX enligt minsta rättighet (least privilege): all inkommande trafik blockeras som standard, och bara den trafik servern behöver släpps igenom.

SRV-02-LNX används bara för backup ([IP-adressplanen](../../reference/ip-plan.md)). Den behöver därför ta emot:

| Trafik | Port | Från | Varför |
|---|---|---|---|
| SSH | 22/tcp | Produktionsnätet 192.168.50.0/24 | Administration av servern |
| SMB3 | 445/tcp | Endast SRV-01-DC, 192.168.50.10 | Windows Server Backup skriver till `\\192.168.50.50\backups` ([backup-guiden](../how-to-backup-windows-server.md)) |

Port 137–139 (NetBIOS) öppnas inte. Backupen använder bara SMB3, som går över port 445.

## 1. Kontrollera att UFW finns

UFW följer med Ubuntu Server. Installera det om det saknas:
```
sudo apt update && sudo apt install ufw
```

Kontrollera status innan du börjar. Det ska stå `Status: inactive`:
```
sudo ufw status
```

## 2. Sätt standardregler

Neka all inkommande trafik och tillåt utgående:
```
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

## 3. Tillåt nödvändig trafik

Är du inloggad via SSH måste SSH-regeln läggas till **innan** UFW aktiveras, annars stänger du ute dig själv.

```
sudo ufw allow from 192.168.50.0/24 to any port 22 proto tcp comment 'SSH från produktionsnätet'
sudo ufw allow from 192.168.50.10 to any port 445 proto tcp comment 'SMB3-backup från SRV-01-DC'
```

## 4. Aktivera loggning och UFW

```
sudo ufw logging on
sudo ufw enable
```

Svara `y` på frågan om att befintliga SSH-anslutningar kan avbrytas.

## 5. Verifiera

Visa reglerna:
```
sudo ufw status verbose
```

Resultatet ska visa `Default: deny (incoming), allow (outgoing)` och exakt de två reglerna:
```
22/tcp                     ALLOW IN    192.168.50.0/24            # SSH från produktionsnätet
445/tcp                    ALLOW IN    192.168.50.10              # SMB3-backup från SRV-01-DC
```

Testa från SRV-01-DC i PowerShell. Det ska stå `TcpTestSucceeded : True`:
```
Test-NetConnection 192.168.50.50 -Port 445
```

Kör samma kommando från en annan dator i produktionsnätet. Där ska det stå `TcpTestSucceeded : False`, eftersom bara SRV-01-DC får nå port 445.

Blockerade anslutningar loggas i `/var/log/ufw.log`.
