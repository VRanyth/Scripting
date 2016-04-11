param
(
	$url = $(Read-Host -Prompt "Site Url"),
    $listName = $(Read-Host -Prompt "ListName")
)

if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) 
{
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
}

cls
write-host("")

$site = new-object Microsoft.SharePoint.SPSite ($url)
$web = $site.OpenWeb()

write-host(“Site : ” + $site.url)

$oList = $web.Lists[$listName]
write-host(“List : ” + $oList.url)

$collListItems = $oList.Items
$count = $collListItems.Count - 1
write-host(“Items Count : ” + $count)

for($intIndex = $count; $intIndex -gt -1; $intIndex--)
{
	write-host("Item: " + $collListItems[$intIndex]["Title"])
	$collListItems.Delete($intIndex)      
} 

write-host(“All Items deleted.”)