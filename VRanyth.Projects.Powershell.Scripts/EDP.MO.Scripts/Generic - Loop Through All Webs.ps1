if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) 
{
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
}

cls
write-host("")
$url = "http://shp2010dev:22222"
#$url = "http://m01-mo.edp.pt/"
#$url = "http://mo.edp.pt/"

$site = new-object Microsoft.SharePoint.SPSite ($url)

function ProcessSubWebs($str)
{
    $currentWeb = Get-SPWeb $str

    ExecuteOnCurrentWeb $currentWeb

    if([Microsoft.SharePoint.Publishing.PublishingWeb]::IsPublishingWeb($currentWeb))
    {
        $publishingWeb = [Microsoft.SharePoint.Publishing.PublishingWeb]::GetPublishingWeb($currentWeb)
        Write-Host -ForegroundColor Green "Processing Web:   " $publishingWeb.Url
        Write-Host -ForegroundColor Green ""

        $publishingPages = $publishingWeb.GetPublishingPages()

        Write-Host  ""

        foreach ($publishingPage in $publishingPages)
        {
            if($publishingPage.ListItem['Title'] -ne $null)
            {   
                
            }
        }
        foreach($sub in $currentWeb.Webs)
        {
            if($sub.Webs.Count -gt 0)
            {
                ProcessSubWebs($sub.Url)
            }
        }
    }
    else
    {
        Write-Host -Foregroundcolor Red "$str not a publishing site"
    }
}

function ExecuteOnCurrentWeb($web)
{     
    $web.QuickLaunchEnabled = $false
    $web.TreeViewEnabled = $false

    $web.Update()
}

ProcessSubWebs($url)



