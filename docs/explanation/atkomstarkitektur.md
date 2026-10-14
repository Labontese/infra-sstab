# Förklaring: Varför åtkomsten är byggd som den är

Proxmox-noden `pve` (10.10.0.2–3) ligger på hemmanätet och exponeras **inte** direkt mot internet. Två separata vägar in täcker olika behov:

**SSH, hemma vs. borta.** När du sitter på samma LAN går SSH direkt till noden – enklast och snabbast, inget beroende av tredje part. Borta från hemmanätet finns ingen direkt väg in (porten är inte öppnad mot internet av säkerhetsskäl), så SSH hoppar istället via `ub-chas-srv01` – en VM (VMID 208) som själv körs *på* samma Proxmox-nod men nås utifrån över Tailscale. Tailscale ger ett säkert mesh-nät utan att noden behöver en publik IP eller öppna brandväggsportar. `~/.ssh/config` avgör automatiskt vilken väg som gäller genom att testa om port 22 på noden går att nå direkt (se [how-to/kom-at-proxmox-hemma-och-bortifran.md](../how-to/kom-at-proxmox-hemma-och-bortifran.md)) – du slipper komma ihåg var du är.

**Webb-UI via Cloudflare.** Proxmox-gränssnittet (port 8006) nås istället via Cloudflare, troligen Cloudflare Tunnel + Access – samma motivation som Tailscale-vägen: ingen öppen port mot internet, men med inloggning/åtkomstkontroll i Cloudflare istället för ett VPN-klientkrav. *(TODO: Daniel fyller på de exakta detaljerna – tunnel-namn, vilken tjänst den pekar på, Access-policy.)*

Gemensamt mönster: lita på perimeterlösa nät (Tailscale, Cloudflare Access) istället för att öppna portar i hemroutern.
