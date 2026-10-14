# How-to: Komma åt Proxmox-noden hemifrån och bortifrån

SSH-aliaset `pve` i `~/.ssh/config` väljer väg automatiskt beroende på var du sitter:

```
Match host pve exec "timeout 1 bash -c \"</dev/tcp/10.10.0.3/22\" 2>/dev/null"
    HostName 10.10.0.3
    User root
    ProxyJump none

Host pve
    HostName 10.10.0.3
    User root
    ProxyJump daniel@ub-chas-srv01
    ServerAliveInterval 30
```

- **Hemma** (samma LAN, `10.10.0.0/24` nås direkt): `Match`-blocket testar om port 22 på `10.10.0.3` är nåbar inom 1 sekund. Om ja hoppar SSH *inte* via någon mellanstation (`ProxyJump none`).
- **Bortifrån**: testet i `Match`-blocket misslyckas (timeout), så den vanliga `Host pve`-regeln gäller istället – SSH hoppar via `daniel@ub-chas-srv01`, som nås över Tailscale.

Använd det alltid som:
```
ssh pve "qm list"
```
– du behöver inte själv veta om du är hemma eller borta.

För webb-UI (`https://<nod>:8006`) nås Proxmox istället via Cloudflare (Tunnel/Access). *(TODO: Daniel fyller på exakt tunnel-/hostnamn och Access-policy här.)*
