# Répertoires
$Backup = "D:\Backup"
$DropboxDirectory = ".\Dropbox"
$LocalDirectory = "D:\"
$PulledDirectory = $args[0]

# Créer un dossier backup pour y mettre un historique
if (-NOT (Test-Path $Backup)) 
{
   New-Item -Path $Backup -ItemType Directory 
}

$operation = "_pull"
$datetime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

# Vérifier si le dossier dans le dropbox existe
if ((Test-Path "$DropboxDirectory\$PulledDirectory") -and
    (Test-Path "$LocalDirectory\$PulledDirectory"))
{
    # Sauvegarder une nouvelle histoire
    Move-Item -Path "$LocalDirectory\$PulledDirectory" -Destination "$Backup\$datetime$operation" -Force

    $History = Get-ChildItem $Backup
    # Si on a plus que 20 histoires on supprime les plus vielles histoires
    $HistoryCount = ($History | Measure-Object ).Count
    
    if ($HistoryCount -gt 20)
    {
    
        $SortedHistory = $History | Sort-Object CreationTime 
        $HistoryToDelete = $SortedHistory[0]
        Remove-Item -Path "$Backup\$HistoryToDelete" -Recurse -Force
    }
}

if (Test-Path "$DropboxDirectory\$PulledDirectory")
{
    # TODO : Copier seulement les fichiers non présents ou modifier et supprimer les fichiers non présents
    #        au lieu de tout supprimer.
    Copy-Item -Path "$DropboxDirectory\$PulledDirectory" -Destination "$LocalDirectory\" -Recurse -Force
}
