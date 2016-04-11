if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) 
{
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
}

cls
write-host("")
$url = "http://shp2010dev:22222/"
#$url = "http://m01-mo.edp.pt/"
#$url = "http://mo.edp.pt/"

$docLibUrl = "http://mo.edp.pt/ChaptersToDownload"

$web = Get-SPWeb -Identity $url
$list = $web.GetList($docLibUrl)

function DeleteFiles {
    param($folderUrl)
    $folder = $web.GetFolder($folderUrl)
    foreach ($file in $folder.Files) {
        # Delete file by deleting parent SPListItem
        Write-Host("Deleted File: " + $file.name)
        $list.Items.DeleteItemById($file.Item.Id)
    }
}

# Delete root files
Write-Host("Preparing to delete Files and Folders on Doc. Lib.: " + $list.Name)
DeleteFiles($list.RootFolder.Url)

# Delete files in folders
foreach ($folder in $list.Folders) {
    DeleteFiles($folder.Url)
}

# Delete folders
foreach ($folder in $list.Folders) {
    try {
        Write-Host("Deleted Folder: " + $folder.name)
        $list.Folders.DeleteItemById($folder.ID)
    }
    catch {
        # Deletion of parent folder already deleted this folder
    }
}

