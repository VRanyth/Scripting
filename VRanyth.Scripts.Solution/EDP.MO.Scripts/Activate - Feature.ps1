if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) 
{
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
}
cls
write-host("")
$url = "http://shp2010dev:22222/"
#$url = "http://m01-mo.edp.pt/"
#$url = "http://mo.edp.pt/"

$featureId = "c75ebe6d-c457-41a8-a035-82725ed0e6d2"

Enable-SPFeature -Identity $featureId -url $url #-erroraction SilentlyContinue    