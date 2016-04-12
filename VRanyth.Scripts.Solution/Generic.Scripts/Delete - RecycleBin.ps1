param
(
	[Parameter(Mandatory=$True)]	
	$url = $(Read-Host -Prompt "SiteCollection Url")
)

Add-PSSnapin "Microsoft.SharePoint.PowerShell"  -ErrorAction SilentlyContinue
 
$site = New-Object Microsoft.SharePoint.SPSite($url)

cls
write-host(“## Starting script on Site Collection Url : ” + $site.url + " ##")
write-host("")

write-host(“Items to be deleted : ” + $site.RecycleBin.Count.toString())

$site.RecycleBin.DeleteAll();

$now = Get-Date

write-host(“Deleting completed at ” +$now.toString())

$site.Dispose();