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
    Copy-Item -Path "$DropboxDirectory\$PushedDirectory" -Destination "$Backup\$datetime$operation" -Recurse -Force
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
     $files = Get-ChildItem –Path  "$LocalDirectory\$PushedDirectory" -Recurse -Force -Attributes !Directory

     for ($i=0; $i -lt $files.Count; $i++)
    {
        $test = [regex]::split($files[$i].FullName, "D:\\")
        $towrite = "$DropboxDirectory\"+$test[1]
        if (Test-Path $towrite)
        {
            $fileTmp = Get-Item $towrite
            if($fileTmp.LastWriteTime -lt $files[$i].LastWriteTime)
            {
                Write-Host $fileTmp
                Copy-Item -Path $files[$i].FullName -Destination $fileTmp -Recurse -Force
            }

        }
        else
        {
            Write-Host $towrite
            New-Item -ItemType File -Path $towrite -Force
            Copy-Item -Path $files[$i].FullName -Destination $towrite -Force
        }
    }
    
#    Copy-Item -Path "$LocalDirectory\$PushedDirectory" -Destination "$DropboxDirectory\" -Recurse -Force
}
