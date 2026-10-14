# Förklaring: Varför test-sstab är byggd som den är

**Klonad från mall, inte manuellt installerad.** En cloud-init-mall (`ubuntu-2404-cloudinit`) ger en färdig, reproducerbar bas – `qm clone ... --full true` tar några minuter istället för en hel ISO-installation, och resultatet är identiskt varje gång. Det gör det enkelt att göra om samma sak för skoluppgiften om servern behöver återskapas.

**DHCP istället för statisk IP.** Mallens nätverkskonfiguration ger servern en adress automatiskt. Enklare att sätta upp, men priset är att IP-adressen inte är känd i förväg – därför behövs ett sätt att slå upp den efteråt (se [how-to/kom-at-test-sstab.md](../how-to/kom-at-test-sstab.md)).

**Åtkomst via Proxmox-noden `pve`.** Servern ligger inte på en egen publik adress, utan nås genom att först SSH:a till Proxmox-noden (hemifrån direkt, bortifrån via Tailscale-hoppet över `ub-chas-srv01`) och sedan vidare till serverns egen IP. Samma mönster som för övriga VM:ar på noden – ingen specialanpassning gjordes för test-sstab.

Utöver detta finns en Cloudflare Tunnel för fjärråtkomst till Proxmox (t.ex. webb-UI) utan att öppna portar mot internet. *(TODO: Daniel fyller på tunnelns namn/hostnamn och vad den exponerar.)*
