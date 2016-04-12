param
(
	[Parameter(Mandatory=$True)]
	$url = $(Read-Host -Prompt "SiteCollection Url")
)

Add-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue

cls

$Logfile = New-Item MissingVariationChapters.csv -type file -force

Function LogWrite
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
}

$site = new-object Microsoft.SharePoint.SPSite ($url)

$pages = New-Object System.Collections.ArrayList
$errors = New-Object System.Collections.ArrayList


function ProcessSubWebs($str)
{
    $currentWeb = Get-SPWeb $str
    if([Microsoft.SharePoint.Publishing.PublishingWeb]::IsPublishingWeb($currentWeb))
    {
        $publishingWeb = [Microsoft.SharePoint.Publishing.PublishingWeb]::GetPublishingWeb($currentWeb)
        Write-Host -ForegroundColor Green "Processing Web:   " $publishingWeb.Url
        Write-Host -ForegroundColor Green ""      

        $publishingPages = $publishingWeb.GetPublishingPages()

        $variation = $publishingWeb.Url.Split("/")[3]

        Write-Host -ForegroundColor White "     - Looping through pages on Web variation: " $variation
        Write-Host  ""

        foreach ($publishingPage in $publishingPages)
        {
            if($publishingPage.ListItem['Title'] -ne $null)
            {   
                if($publishingPage.ListItem["ContentNotAvailableFld"])
                {   
                    $pages.Add(("{0}/{1}" -f $publishingWeb.Url,$publishingPage.ListItem.Url))

                    $c = $publishingWeb.Url.replace($variation, $publishingPage.ListItem["DefaultContentLanguageFld"])
  
                    Write-Host -ForegroundColor Yellow "     - Content not available on Variation [$variation]:"

                    Write-Host -ForegroundColor Yellow  ("      {0}/{1}" -f $publishingWeb.Url,$publishingPage.ListItem.Url)
                    Write-Host -ForegroundColor Yellow ""
                    Write-Host -ForegroundColor Yellow "      Checking on Default variation: " $publishingPage.ListItem["DefaultContentLanguageFld"]
                    Write-Host -ForegroundColor Yellow ""

                    GetDefaultVariationPageUrl $c $publishingPage.ListItem.Url $variation
                }
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

function GetDefaultVariationPageUrl([string]$variationUrl, [string]$sourcePageUrl, [string]$variation)
{
    $variationWeb = Get-SPWeb $variationUrl.ToString()

    if([Microsoft.SharePoint.Publishing.PublishingWeb]::IsPublishingWeb($variationWeb))
    {
        $exists = $false

        $publishingWeb = [Microsoft.SharePoint.Publishing.PublishingWeb]::GetPublishingWeb($variationWeb)
        $publishingPages = $publishingWeb.GetPublishingPages()
        
        foreach ($publishingPage in $publishingPages)
        {
            if(!$publishingPage.ListItem["ContentNotAvailableFld"])
            {
                if($publishingPage.ListItem.Url -eq $sourcePageUrl)
                {
                    $exists = $true
                }
            }
        }
        
        if(!$exists)
        {
            Write-Host -ForegroundColor DarkRed "------------------------------------------------------------------------------------------------------------"
            Write-Host -ForegroundColor Red "Not Found" $variationUrl"/"$sourcePageUrl
            Write-Host -ForegroundColor DarkRed "------------------------------------------------------------------------------------------------------------"
            $errors.Add(("{0}/{1} || {2}" -f $variationUrl,$sourcePageUrl, $variation))
            
            LogWrite ("{0}/{1};{2}" -f $variationUrl,$sourcePageUrl, $variation)
        }
        else
        {
            Write-Host -ForegroundColor DarkRed "      ----------------"
            Write-Host -ForegroundColor Green "        Found match!  "
            Write-Host -ForegroundColor DarkRed "      ----------------"
        }
        
        Write-Host ""
       
    }
}

LogWrite ("{0};{1}" -f "Page Url","Default Variation")
ProcessSubWebs($url)

Write-Host -ForegroundColor DarkRed "------------------------------------------------------------------------"

Write-Host -ForegroundColor Green "Resume Log:"
Write-Host -ForegroundColor Green $pages.Count " Pages where processed!"
Write-Host -ForegroundColor Red $errors.Count " Pages don't have a match!"
 
Write-Host -ForegroundColor DarkRed "------------------------------------------------------------------------"

Write-Host -ForegroundColor DarkRed "End!"


