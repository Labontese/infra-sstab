# fildelning.ps1
# Mappar, NTFS-behörigheter och SMB-delningar för avdelningarna enligt
# docs/reference/Fildelning.md. Körs som domänadministratör på SRV-01-DC,
# efter ad-struktur.ps1. Tål att köras om.
#
#   .\fildelning.ps1
#
# Sparas som UTF-8 med BOM, annars blir å, ä och ö fel i Windows PowerShell 5.1.
$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory

$netbios = (Get-ADDomain).NetBIOSName      # SOST
$rot = 'C:\Fildelning'
$mappar = [ordered]@{
    'HR'                  = @{ Grupp = 'dl-hr-rw';        Ntfs = 'M' }
    'Ledning'             = @{ Grupp = 'dl-ledning-rw';   Ntfs = 'M' }
    'Ekonomi'             = @{ Grupp = 'dl-ekonomi-rw';   Ntfs = 'M' }
    'Lager'               = @{ Grupp = 'dl-lager-rw';     Ntfs = 'M' }
    'IT'                  = @{ Grupp = 'dl-it-rw';        Ntfs = 'M' }
    'Gemensamma dokument' = @{ Grupp = 'dl-gemensamt-ro'; Ntfs = 'RX' }
}

# Steg 1: huvudmappen
New-Item -ItemType Directory -Path $rot -Force | Out-Null

foreach ($namn in $mappar.Keys) {
    $m = $mappar[$namn]
    $mapp = Join-Path $rot $namn
    $grupp = "$netbios\$($m.Grupp)"
    New-Item -ItemType Directory -Path $mapp -Force | Out-Null

    # Steg 2: NTFS. Arvet bryts, så att Users försvinner. SYSTEM, Administrators och
    # CREATOR OWNER behålls, och den domänlokala gruppen får Modify eller Read & execute.
    icacls $mapp /inheritance:r | Out-Null
    icacls $mapp /grant:r 'SYSTEM:(OI)(CI)F' 'BUILTIN\Administrators:(OI)(CI)F' 'CREATOR OWNER:(OI)(CI)(IO)F' `
        "$($grupp):(OI)(CI)$($m.Ntfs)" | Out-Null

    # Steg 3: SMB. Bara den domänlokala gruppen, inte Everyone.
    if (-not (Get-SmbShare -Name $namn -ErrorAction SilentlyContinue)) {
        if ($m.Ntfs -eq 'M') { New-SmbShare -Name $namn -Path $mapp -ChangeAccess $grupp | Out-Null }
        else                 { New-SmbShare -Name $namn -Path $mapp -ReadAccess $grupp | Out-Null }
    }
}

# Kontroll: delningarna och vem som har åtkomst
Get-SmbShare | Where-Object Path -like "$rot\*" | Sort-Object Name | ForEach-Object {
    [pscustomobject]@{
        Delning = $_.Name
        Smb     = (Get-SmbShareAccess $_.Name | ForEach-Object { "$($_.AccountName) $($_.AccessRight)" }) -join ', '
        Ntfs    = ((Get-Acl $_.Path).Access | Where-Object IdentityReference -like "$netbios\dl-*" |
                   ForEach-Object { "$($_.IdentityReference) $($_.FileSystemRights)" }) -join ', '
    }
} | Format-Table -AutoSize -Wrap
