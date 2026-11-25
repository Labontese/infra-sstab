# minsta-rattighet.ps1
# GPO:n "CIS - Least Privilege DC" och delegeringen till gg-it enligt
# docs/reference/least-privilege.md (CIS Microsoft Windows Server 2025
# Benchmark v2.1.0, kapitel 2.2). Körs som domänadministratör på SRV-01-DC,
# efter ad-struktur.ps1. Tål att köras om.
#
#   .\minsta-rattighet.ps1
#
# Sparas som UTF-8 med BOM, annars blir å, ä och ö fel i Windows PowerShell 5.1.
$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory, GroupPolicy

$namn = 'CIS - Least Privilege DC'
$doman = Get-ADDomain
$dc = $doman.DomainControllersContainer

# Steg 2: GPO:n, länkad bara till Domain Controllers. Länkordning 1, eftersom
# Default Domain Controllers Policy också är länkad där och sätter flera av samma
# rättigheter. Den GPO som har lägst länkordning vinner.
$gpo = Get-GPO -Name $namn -ErrorAction SilentlyContinue
if (-not $gpo) { $gpo = New-GPO -Name $namn -Comment 'CIS 2.2 User Rights Assignment för domänkontrollanter' }
if (-not ((Get-GPInheritance $dc).GpoLinks | Where-Object DisplayName -eq $namn)) {
    New-GPLink -Name $namn -Target $dc | Out-Null
}
Set-GPLink -Name $namn -Target $dc -Order 1 | Out-Null

# Steg 3: User Rights Assignment enligt tabellen. Kända SID: Administrators
# S-1-5-32-544, Guests S-1-5-32-546, ENTERPRISE DOMAIN CONTROLLERS S-1-5-9.
$anstallda = (Get-ADGroup 'gg-anstallda').SID.Value
$mall = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
Revision=1
[Privilege Rights]
SeMachineAccountPrivilege = *S-1-5-32-544
SeInteractiveLogonRight = *S-1-5-32-544,*S-1-5-9
SeRemoteInteractiveLogonRight = *S-1-5-32-544
SeDebugPrivilege = *S-1-5-32-544
SeDenyInteractiveLogonRight = *S-1-5-32-546,*$anstallda
SeDenyRemoteInteractiveLogonRight = *S-1-5-32-546,*$anstallda
SeShutdownPrivilege = *S-1-5-32-544
"@
$sysvol = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters').SysVol
$gpoRot = "$sysvol\$($doman.DNSRoot)\Policies\{$($gpo.Id)}"
$secedit = "$gpoRot\Machine\Microsoft\Windows NT\SecEdit"
New-Item -ItemType Directory -Path $secedit -Force | Out-Null
Set-Content -Path "$secedit\GptTmpl.inf" -Value $mall -Encoding Unicode

# Datorerna läser bara säkerhetsinställningarna om GPO:n har klienttillägget för
# säkerhet, och om datordelen av versionen räknas upp i både AD och GPT.INI.
$gpoDn = "CN={$($gpo.Id)},CN=Policies,CN=System,$($doman.DistinguishedName)"
Set-ADObject $gpoDn -Replace @{
    gPCMachineExtensionNames = '[{827D319E-6EAC-11D2-A4EA-00C04F79F83A}{803E14A0-B4FB-11D0-A0D0-00A0C90F574B}]'
}
$version = [long](Get-ADObject $gpoDn -Properties versionNumber).versionNumber
$ny = ($version -band 0xFFFF0000) -bor ((($version -band 0xFFFF) + 1) -band 0xFFFF)
Set-ADObject $gpoDn -Replace @{ versionNumber = [int]$ny }
Set-Content -Path "$gpoRot\GPT.INI" -Value "[General]`r`nVersion=$ny" -Encoding ASCII

# Steg 5: gg-it får skapa, ta bort och hantera användarkonton och byta lösenord i
# SkamtSidoTransport, samma rättigheter som guiden Delegate Control ger.
$ou = "OU=SkamtSidoTransport,$($doman.DistinguishedName)"
dsacls $ou /I:T /G "$($doman.NetBIOSName)\gg-it:CCDC;user" | Out-Null
dsacls $ou /I:S /G "$($doman.NetBIOSName)\gg-it:GA;;user" | Out-Null

# Steg 6: tillämpa och kontrollera
gpupdate /target:computer /force | Out-Null
(Get-GPInheritance $dc).GpoLinks | Format-Table Order, DisplayName -AutoSize
gpresult /r /scope computer | Select-String -SimpleMatch $namn
