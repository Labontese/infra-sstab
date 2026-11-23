#!/bin/bash

# Sakerstall att arkivkatalogen finns
mkdir -p /srv/backup/archive

# 1. Hamta dagens datum
DATUM=$(date +%Y-%m-%d)

# 2. Packa ihop och komprimera backup-mappen
tar -czf /srv/backup/archive/backup_$DATUM.tar.gz -C /srv/backup/windows .

# 3. Gor arkivet skrivskyddat (skydd mot manipulation/ransomware)
chmod 400 /srv/backup/archive/backup_$DATUM.tar.gz

# 4. Rensa arkivfiler aldre an 30 dagar
find /srv/backup/archive/ -name *.tar.gz -mtime +30 -delete
