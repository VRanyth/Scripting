param
(
	$url = $(Read-Host -Prompt "SiteCollection Url")
)

if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) 
{
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
}

cls
write-host("")

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

#put here what you would like to run on Webs
function ExecuteOnCurrentWeb($web)
{     
    $web.QuickLaunchEnabled = $false
    $web.TreeViewEnabled = $false
    $web.Update()
}

ProcessSubWebs($url)



