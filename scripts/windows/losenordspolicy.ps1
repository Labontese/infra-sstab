# losenordspolicy.ps1
# Lösenords- och utlåsningspolicy enligt docs/reference/losenordspolicy.md
# (CIS Microsoft Windows Server 2025 Benchmark v2.1.0, kapitel 1): en PSO per
# avdelning (steg 2–3) och Default Domain Policy (steg 6). Körs som
# domänadministratör på SRV-01-DC, efter ad-struktur.ps1. Tål att köras om.
#
#   .\losenordspolicy.ps1
#
# Sparas som UTF-8 med BOM, annars blir å, ä och ö fel i Windows PowerShell 5.1.
$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory

# Steg 2: samma värden för PSO:erna och Default Domain Policy
$pso = @{
    PasswordHistoryCount        = 24             # CIS 1.1.1
    MaxPasswordAge              = '100.00:00:00' # CIS 1.1.2
    MinPasswordAge              = '1.00:00:00'   # CIS 1.1.3
    MinPasswordLength           = 14             # CIS 1.1.4
    ComplexityEnabled           = $true          # CIS 1.1.5
    ReversibleEncryptionEnabled = $false         # CIS 1.1.7
    LockoutDuration             = '00:30:00'     # CIS 1.2.1
    LockoutThreshold            = 5              # CIS 1.2.2
    LockoutObservationWindow    = '00:15:00'     # CIS 1.2.4
}

# Steg 2–3 och Precedence per avdelning: PSO:n kopplas till avdelningens grupp
$avdelningar = [ordered]@{ Ledning = 10; IT = 20; Ekonomi = 30; HR = 40; Lager = 50 }
foreach ($a in $avdelningar.Keys) {
    $namn = "pso-$($a.ToLower())"
    $grupp = Get-ADGroup "gg-$($a.ToLower())"
    $finns = Get-ADFineGrainedPasswordPolicy -Filter "Name -eq '$namn'" -Properties AppliesTo
    if ($finns) {
        Set-ADFineGrainedPasswordPolicy -Identity $namn -Precedence $avdelningar[$a] @pso
    } else {
        New-ADFineGrainedPasswordPolicy -Name $namn -Precedence $avdelningar[$a] `
            -Description "För samtliga $a arbetare" -ProtectedFromAccidentalDeletion $true @pso
    }
    if (-not $finns -or $finns.AppliesTo -notcontains $grupp.DistinguishedName) {
        Add-ADFineGrainedPasswordPolicySubject -Identity $namn -Subjects $grupp
    }
}

# Steg 6: Default Domain Policy. Värdena skrivs i GPO:ns säkerhetsmall. Det räcker
# inte med Set-ADDefaultDomainPasswordPolicy, eftersom domänkontrollanten skriver
# tillbaka GPO:ns värden vid nästa uppdatering. Åldrar i dagar, tider i minuter.
$systemAccess = [ordered]@{
    PasswordHistorySize = 24; MaximumPasswordAge = 100; MinimumPasswordAge = 1
    MinimumPasswordLength = 14; PasswordComplexity = 1; ClearTextPassword = 0
    LockoutDuration = 30; LockoutBadCount = 5; ResetLockoutCount = 15
}
$doman = Get-ADDomain
$guid = '{31B2F340-016D-11D2-945F-00C04FB984F9}'   # Default Domain Policy, samma i alla domäner
$sysvol = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters').SysVol
$gpoRot = "$sysvol\$($doman.DNSRoot)\Policies\$guid"
$fil = "$gpoRot\Machine\Microsoft\Windows NT\SecEdit\GptTmpl.inf"
$rader = [Collections.Generic.List[string]](Get-Content $fil)
$start = $rader.IndexOf('[System Access]')
if ($start -lt 0) { $rader.Add('[System Access]'); $start = $rader.Count - 1 }
$slut = $start + 1
while ($slut -lt $rader.Count -and -not $rader[$slut].StartsWith('[')) { $slut++ }
foreach ($nyckel in $systemAccess.Keys) {
    $rad = "$nyckel = $($systemAccess[$nyckel])"
    $i = -1
    for ($j = $start + 1; $j -lt $slut; $j++) { if ($rader[$j] -match "^$nyckel\s*=") { $i = $j } }
    if ($i -ge 0) { $rader[$i] = $rad } else { $rader.Insert($slut, $rad); $slut++ }
}
Set-Content -Path $fil -Value $rader -Encoding Unicode

# Datordelen av GPO:ns version räknas upp, annars tror domänkontrollanten att inget ändrats
$gpoDn = "CN=$guid,CN=Policies,CN=System,$($doman.DistinguishedName)"
$version = [long](Get-ADObject $gpoDn -Properties versionNumber).versionNumber
$ny = ($version -band 0xFFFF0000) -bor ((($version -band 0xFFFF) + 1) -band 0xFFFF)
Set-ADObject $gpoDn -Replace @{ versionNumber = [int]$ny }
(Get-Content "$gpoRot\GPT.INI") -replace '^Version=\d+', "Version=$ny" | Set-Content "$gpoRot\GPT.INI" -Encoding ASCII
gpupdate /target:computer /force | Out-Null

# Kontroll
Get-ADDefaultDomainPasswordPolicy |
    Format-List MinPasswordLength, ComplexityEnabled, PasswordHistoryCount, MinPasswordAge, MaxPasswordAge,
                LockoutThreshold, LockoutDuration, LockoutObservationWindow
Get-ADFineGrainedPasswordPolicy -Filter * -Properties AppliesTo | Sort-Object Precedence |
    Format-Table Name, Precedence, @{ n = 'Kopplad till'; e = { ($_.AppliesTo | ForEach-Object { (Get-ADGroup $_).Name }) -join ', ' } } -AutoSize
