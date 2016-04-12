param
(
	[Parameter(Mandatory=$True)]
	$url = $(Read-Host -Prompt "Site Url"),

	[Parameter(Mandatory=$True)]
    $listName = $(Read-Host -Prompt "ListName")
)

Add-PSSnapin "Microsoft.SharePoint.PowerShell"  -ErrorAction SilentlyContinue

$site = new-object Microsoft.SharePoint.SPSite ($url)

cls
write-host(“## Starting script on Site Collection Url : ” + $site.url + " ##")
write-host("")

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