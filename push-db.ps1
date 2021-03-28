# Répertoires
$Backup = "D:\Backup"
$DropboxDirectory = ".\Dropbox"
$LocalDirectory = "D:\"
$PushedDirectory = $args[0]

# Créer un dossier backup pour y mettre un historique
if (-NOT (Test-Path $Backup)) 
{
   New-Item -Path $Backup -ItemType Directory 
}

$operation = "_push"
$datetime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

# Vérifier si le dossier dans le dropbox existe pour l'historique
if ((Test-Path "$DropboxDirectory\$PushedDirectory") -and
    (Test-Path "$LocalDirectory\$PushedDirectory"))
{
    # Sauvegarder une nouvelle histoire
    Move-Item -Path "$DropboxDirectory\$PushedDirectory" -Destination "$Backup\$datetime$operation" -Force

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

if (Test-Path "$LocalDirectory\$PushedDirectory")
{
    # TODO : Copier seulement les fichiers non présents ou modifier et supprimer les fichiers non présents
    #        au lieu de tout supprimer.
    Copy-Item -Path "$LocalDirectory\$PushedDirectory" -Destination "$DropboxDirectory\" -Recurse -Force
}
