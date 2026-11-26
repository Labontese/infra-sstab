# startsida.ps1
# GPO:n "Klienter - Startsida" enligt docs/how-to/startsida-gpo.md: Edge på klienterna
# i OU:n Datorer har startsidan på SRV-02-LNX (http://192.168.50.50/) och öppnas med
# den när någon loggar in. Körs som domänadministratör på SRV-01-DC. Tål att köras om.
#
#   .\startsida.ps1
#
# Sparas som UTF-8 med BOM, annars blir å, ä och ö fel i Windows PowerShell 5.1.
$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory, GroupPolicy

$namn = 'Klienter - Startsida'
$ou   = "OU=Datorer,OU=SkamtSidoTransport,$((Get-ADDomain).DistinguishedName)"
$url  = 'http://192.168.50.50/'
$edge = 'HKLM\Software\Policies\Microsoft\Edge'

# Steg 1: GPO:n, länkad till OU:n Datorer
$gpo = Get-GPO -Name $namn -ErrorAction SilentlyContinue
if (-not $gpo) { $gpo = New-GPO -Name $namn -Comment "Startsidan i Edge på klienterna: $url" }
if (-not ((Get-GPInheritance $ou).GpoLinks | Where-Object DisplayName -eq $namn)) {
    New-GPLink -Name $namn -Target $ou | Out-Null
}

# Steg 2: startsidan i Edge
Set-GPRegistryValue -Name $namn -Key $edge -ValueName HomepageLocation       -Type String -Value $url | Out-Null
Set-GPRegistryValue -Name $namn -Key $edge -ValueName HomepageIsNewTabPage   -Type DWord  -Value 0    | Out-Null
Set-GPRegistryValue -Name $namn -Key $edge -ValueName ShowHomeButton         -Type DWord  -Value 1    | Out-Null
Set-GPRegistryValue -Name $namn -Key $edge -ValueName RestoreOnStartup       -Type DWord  -Value 4    | Out-Null
Set-GPRegistryValue -Name $namn -Key "$edge\RestoreOnStartupURLs" -ValueName 1 -Type String -Value $url | Out-Null
Set-GPRegistryValue -Name $namn -Key $edge -ValueName HideFirstRunExperience -Type DWord  -Value 1    | Out-Null
Set-GPRegistryValue -Name $namn -Key $edge -ValueName TranslateEnabled       -Type DWord  -Value 0    | Out-Null
# Utan detta startar Edge i bakgrunden vid inloggning utan fönster och tar över starten i steg 3
Set-GPRegistryValue -Name $namn -Key $edge -ValueName StartupBoostEnabled    -Type DWord  -Value 0    | Out-Null

# Steg 3: Edge öppnas vid inloggning ("Run these programs at user logon")
Set-GPRegistryValue -Name $namn -Key 'HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run' `
    -ValueName 1 -Type String -Value "`"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe`" $url" | Out-Null

# Kontroll
"GPO: $namn, länkad till $ou"
Get-GPRegistryValue -Name $namn -Key $edge -ErrorAction SilentlyContinue | Where-Object ValueName |
    ForEach-Object { "  {0} = {1}" -f $_.ValueName, $_.Value }
Get-GPRegistryValue -Name $namn -Key "$edge\RestoreOnStartupURLs" | ForEach-Object { "  RestoreOnStartupURLs\{0} = {1}" -f $_.ValueName, $_.Value }
Get-GPRegistryValue -Name $namn -Key 'HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run' |
    ForEach-Object { "  Run\{0} = {1}" -f $_.ValueName, $_.Value }
