param
(
	[Parameter(Mandatory=$True)]
	$url = $(Read-Host -Prompt "SiteCollection Url"),
	
	[Parameter(Mandatory=$True)]
	$docLibUrl = $(Read-Host -Prompt "DocLib Full Url")
)

Add-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue

cls
write-host("")
#$docLibUrl = "http://mo.edp.pt/ChaptersToDownload"

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

