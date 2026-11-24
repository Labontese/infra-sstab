#!/bin/bash
# Packar nattens Windows Server Backup till ett daterat arkiv på SRV-02-LNX.
# WSB skriver över förra backupen varje natt, så arkivet ger flera versioner.
# Körs kl. 07:00 av cron, se docs/how-to/how-to-backup-windows-server.md.
set -euo pipefail

KALLA=/srv/samba/backups    # delningen som WSB skriver till
ARKIV=/srv/samba/arkiv      # inte utdelad, kan inte ändras från Windows
SPARA=5                     # antal arkiv som sparas

# 1. Hämta dagens datum och det senaste arkivet
START=$(date +%s)           # när körningen började, i sekunder
DATUM=$(date +%Y-%m-%d)
FIL=$ARKIV/backup_$DATUM.tar.gz
SENASTE=$(ls -1 "$ARKIV"/backup_*.tar.gz 2>/dev/null | tail -n 1 || true)

fel() { echo "$(date '+%F %T') FEL: $*" >&2; exit 1; }

# 2. Stoppa om det inte finns någon backup, eller om den har ändrats de
#    senaste 30 minuterna. Då pågår den.
[[ -d "$KALLA/WindowsImageBackup/SRV-01-DC" ]] || fel "ingen backup från SRV-01-DC i $KALLA"
NYLIGEN=$(find "$KALLA" -cmin -30 -print -quit)
[[ -z "$NYLIGEN" ]] || fel "backupen ändrades nyss, försök senare"

# 3. Hoppa över om backupen inte har ändrats sedan förra arkivet. Arkivets tid
#    är när den körningen började, så en ändring under packningen syns här.
if [[ -n "$SENASTE" ]]; then
    NYTT=$(find "$KALLA" -cnewer "$SENASTE" -print -quit)
    if [[ -z "$NYTT" ]]; then
        echo "$(date '+%F %T') OK: ingen ny backup sedan $SENASTE"
        exit 0
    fi
fi

# 4. Packa ihop och komprimera till ett tillfälligt namn och kontrollera att
#    arkivet går att läsa. tar ger fel om en fil ändras medan den läses.
#    Arkivet får sitt riktiga namn först när allt har gått bra.
rm -f "$ARKIV"/backup_*.tar.gz.tmp
if ! tar -czf "$FIL.tmp" -C "$KALLA" . || ! tar -tzf "$FIL.tmp" > /dev/null; then
    rm -f "$FIL.tmp"
    fel "arkivet kunde inte skapas"
fi
chmod 400 "$FIL.tmp"
touch -d "@$START" "$FIL.tmp"
mv "$FIL.tmp" "$FIL"

# 5. Behåll bara de SPARA senaste arkiven. Datumet i namnet gör att ls
#    listar dem från äldst till nyast.
ls -1 "$ARKIV"/backup_*.tar.gz | head -n -"$SPARA" | xargs -r rm -f --

echo "$(date '+%F %T') OK: $FIL ($(du -h "$FIL" | cut -f1))"
