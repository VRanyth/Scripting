if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) 
{
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
}

#$url = "http://shp2010dev:22222/"
$url = "http://m01-mo.edp.pt/"
#$url = "http://mo.edp.pt/"
 
$siteCollection = New-Object Microsoft.SharePoint.SPSite($url)

write-host(“Site Collection Url : ” + $siteCollection.url)

write-host(“Items to be deleted : ” + $siteCollection.RecycleBin.Count.toString())

$siteCollection.RecycleBin.DeleteAll();

$now = Get-Date

write-host(“Deleting completed at ” +$now.toString())

$siteCollection.Dispose();