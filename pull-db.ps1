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
    Copy-Item -Path "$LocalDirectory$PulledDirectory" -Destination "$Backup\$datetime$operation" -Recurse -Force
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
    $files = Get-ChildItem –Path "$DropboxDirectory\$PulledDirectory" -Recurse -Force -Attributes !Directory


    for ($i=0; $i -lt $files.Count; $i++)
    {
        $test = [regex]::split($files[$i].FullName, "D:\\Dropbox\\")
        $towrite = $LocalDirectory+$test[1]
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
    
   
}
