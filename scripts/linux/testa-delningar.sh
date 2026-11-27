#!/bin/bash
# testa-delningar.sh
# Provar delningarna på SRV-01-DC från en Linux-dator i produktionsnätet, som
# testanvändarna från scripts/windows/ad-struktur.ps1. Användaren ska nå sin egen
# avdelning och läsa Gemensamma dokument, men nekas de andra avdelningarna
# (docs/reference/Fildelning.md steg 6 och behörighetsmatrisen i acl/acc-plan.md).
# Varje rad ska ge OK. Skriptet avslutas med felkod 1 om någon rad ger FEL.
#
#   sudo apt install smbclient
#   ./testa-delningar.sh
#
# Lösenordet för testanvändarna frågas efter och hamnar inte i skalhistoriken.
set -uo pipefail

read -rsp 'Lösenord för testanvändarna: ' LOSEN; echo
LOSEN=${LOSEN%$'\r'}          # om lösenordet skickas från Windows
DC=//192.168.50.10            # SRV-01-DC enligt docs/reference/ip-plan.md
AUTH=$(mktemp); chmod 600 "$AUTH"
PROV=$(mktemp); echo "prov $(date +%T)" > "$PROV"
trap 'rm -f "$AUTH" "$PROV"' EXIT
FEL=0

prova() {   # användare, delning, läs|skriv, väntat ja|nej
    printf 'username = %s\npassword = %s\ndomain = SOST\n' "$1" "$LOSEN" > "$AUTH"
    if [[ $3 == läs ]]; then kmd='ls'; else kmd="put $PROV prov-$1.txt; del prov-$1.txt"; fi
    if smbclient "$DC/$2" -A "$AUTH" -m SMB3 -c "$kmd" > /dev/null 2>&1; then fick=ja; else fick=nej; fi
    [[ $fick == "$4" ]] && res=OK || { res=FEL; FEL=1; }
    printf '%-4s %-13s %-20s %-5s väntat %-3s fick %s\n' "$res" "$1" "$2" "$3" "$4" "$fick"
}

prova test-hr      HR                    skriv ja
prova test-hr      Ekonomi               läs   nej
prova test-hr      'Gemensamma dokument' läs   ja
prova test-hr      'Gemensamma dokument' skriv nej
prova test-ekonomi Ekonomi               skriv ja
prova test-ekonomi Lager                 skriv ja
prova test-lager   Lager                 skriv ja
prova test-lager   Ekonomi               läs   nej
prova test-it      IT                    skriv ja
prova test-it      Ledning               läs   nej
prova test-ledning Ledning               skriv ja
prova test-ledning HR                    läs   nej
exit $FEL
