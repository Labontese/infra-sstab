# ad-struktur.ps1
# OU:er, säkerhetsgrupper och testanvändare i sost.local enligt
# docs/reference/OU.md. Körs som domänadministratör på SRV-01-DC.
# Tål att köras om: det som redan finns hoppas över.
#
#   .\ad-struktur.ps1
#
# Lösenordet för testanvändarna frågas efter bara när en användare skapas.
# Det ska följa docs/reference/losenordspolicy.md.
# Sparas som UTF-8 med BOM, annars blir å, ä och ö fel i Windows PowerShell 5.1.
$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory

$doman = Get-ADDomain
$bas = "OU=SkamtSidoTransport,$($doman.DistinguishedName)"
$avdelningar = [ordered]@{
    HR = 'HR-personal'; Ledning = 'Ledningspersonal'; Ekonomi = 'Ekonomipersonal'
    Lager = 'Lagerpersonal'; IT = 'IT-personal'
}
$losenord = $null

function Ny-OU([string]$Namn, [string]$Under) {
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$Namn'" -SearchBase $Under -SearchScope OneLevel)) {
        New-ADOrganizationalUnit -Name $Namn -Path $Under -ProtectedFromAccidentalDeletion $true
    }
}
function Ny-Grupp([string]$Namn, [string]$Omfattning, [string]$Under, [string]$Beskrivning) {
    if (-not (Get-ADGroup -Filter "Name -eq '$Namn'")) {
        New-ADGroup -Name $Namn -GroupScope $Omfattning -GroupCategory Security -Path $Under -Description $Beskrivning
    }
}

# Steg 2: OU-struktur
Ny-OU 'SkamtSidoTransport' $doman.DistinguishedName
foreach ($ou in 'Användare', 'Grupper', 'Datorer') { Ny-OU $ou $bas }
foreach ($a in $avdelningar.Keys) { Ny-OU $a "OU=Användare,$bas" }
foreach ($ou in 'Globala', 'DomanLokala') { Ny-OU $ou "OU=Grupper,$bas" }

# Steg 5: globala grupper
$gg = "OU=Globala,OU=Grupper,$bas"
foreach ($a in $avdelningar.Keys) { Ny-Grupp "gg-$($a.ToLower())" Global $gg $avdelningar[$a] }
Ny-Grupp 'gg-anstallda' Global $gg 'Samtliga anställda'

# Steg 6: domänlokala grupper
$dl = "OU=DomanLokala,OU=Grupper,$bas"
foreach ($a in $avdelningar.Keys) { Ny-Grupp "dl-$($a.ToLower())-rw" DomainLocal $dl "Läs- och skrivbehörighet för $a" }
Ny-Grupp 'dl-gemensamt-ro' DomainLocal $dl 'Läsbehörighet för Gemensamt'

# Steg 8: gruppkopplingar enligt tabellen Gruppkopplingar
$kopplingar = [ordered]@{
    'dl-hr-rw'        = 'gg-hr'
    'dl-ledning-rw'   = 'gg-ledning'
    'dl-ekonomi-rw'   = 'gg-ekonomi'
    'dl-lager-rw'     = 'gg-lager', 'gg-ekonomi'
    'dl-it-rw'        = 'gg-it'
    'dl-gemensamt-ro' = 'gg-anstallda'
}
foreach ($d in $kopplingar.Keys) { Add-ADGroupMember $d -Members $kopplingar[$d] }

# Steg 3 och 7: en testanvändare per avdelning, med i avdelningens grupp och gg-anstallda
foreach ($a in $avdelningar.Keys) {
    $sam = "test-$($a.ToLower())"
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$sam'")) {
        if (-not $losenord) { $losenord = Read-Host 'Lösenord för testanvändarna' -AsSecureString }
        New-ADUser -SamAccountName $sam -UserPrincipalName "$sam@$($doman.DNSRoot)" -Name "Test $a" `
            -GivenName 'Test' -Surname $a -DisplayName "Test $a" -Path "OU=$a,OU=Användare,$bas" `
            -AccountPassword $losenord -Enabled $true
    }
    Add-ADGroupMember "gg-$($a.ToLower())" -Members $sam
    Add-ADGroupMember 'gg-anstallda' -Members $sam
}

# Steg 9: kontrollera grupperna och deras medlemmar
Get-ADGroup -Filter "Name -like 'gg-*' -or Name -like 'dl-*'" -SearchBase $bas | Sort-Object Name |
    ForEach-Object {
        [pscustomobject]@{
            Grupp     = $_.Name
            Medlemmar = (Get-ADGroupMember $_ | Select-Object -ExpandProperty Name | Sort-Object) -join ', '
        }
    } | Format-Table -AutoSize -Wrap
