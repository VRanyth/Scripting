param
(
	[Parameter(Mandatory=$True)]
	$url = $(Read-Host -Prompt "SiteCollection Url"),
	
	[Parameter(Mandatory=$True)]
	$takeActions = $(Read-Host -Prompt "Execute Actions(checkin/publish/aprove)?:")
)

Add-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue

cls

Write-Host -ForegroundColor Green ""
Write-Host -ForegroundColor Green "Executing script:"
Write-Host -ForegroundColor Green ""  

if($takeActions -eq "true")
{
	Write-Host -ForegroundColor RED "You have activated [Execute Actions] flag, all checkedout/unpublished pages will be Automatically checkedin/published/aproved."
}
else
{
	Write-Host -ForegroundColor RED "You have not activated [Execute Actions] flag, all pages will retain current status, just logging."
}
Write-Host -ForegroundColor Green "" 

$Logfile = New-Item MO_Logging_CheckedOutNonPublishedChapters.csv -type file -force

Function LogWrite
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
}

$site = new-object Microsoft.SharePoint.SPSite ($url)

$pages = New-Object System.Collections.ArrayList

function ProcessSubWebs($str)
{
    $currentWeb = Get-SPWeb $str
    if([Microsoft.SharePoint.Publishing.PublishingWeb]::IsPublishingWeb($currentWeb))
    {
        $publishingWeb = [Microsoft.SharePoint.Publishing.PublishingWeb]::GetPublishingWeb($currentWeb)
        Write-Host -ForegroundColor Green ""
		Write-Host -ForegroundColor Green "Processing Web:   " $publishingWeb.Url
        Write-Host -ForegroundColor Green ""      

        $publishingPages = $publishingWeb.GetPublishingPages()

        Write-Host -ForegroundColor White "     - Looping through pages on Web:"
        Write-Host  ""

        foreach ($publishingPage in $publishingPages)
        {
			$item = $publishingPage.ListItem
            if($item['Title'] -ne $null)
            {   
                $itemFile = $item.File

				Write-Host -ForegroundColor white " - Processing Page:" $item.Url

				LogWrite ("{0};{1};{2};{3};{4}" -f $item.Url,$item.Versions[0].Level, $item.ModerationInformation.Status, $itemFile.CheckOutStatus, $itemFile.CheckedOutByUser)
				
				$errors = $false
				

				if($itemFile.CheckOutStatus -ne "None" )
				{ 	
					Write-Host -ForegroundColor red "     -              CheckOut:" $itemFile.CheckOutStatus
					Write-Host -ForegroundColor red "     -           CheckOut By:" $itemFile.CheckedOutByUser
					
					if($takeActions -eq "true")
					{
						$itemFile.CheckIn("Automatic CheckIn. (Administrator)")
					}
				}
				if ($item.Versions[0].Level -ne "Published")
				{
					Write-Host -ForegroundColor red "     -                 Level:" $item.Versions[0].Level
					
					if($takeActions -eq "true")
					{
						$itemFile.Publish("Automatically published. (Administrator)")
					}
				}
				if ($item.ModerationInformation.Status -ne "Approved")
				{
					Write-Host -ForegroundColor red "     - ModerationInformation:" $item.ModerationInformation.Status
					if($takeActions -eq "true")
					{
						$itemFile.Approve("Automatically approved. (Administrator)")
					}
				}
				if($errors)
				{
					Write-Host -ForegroundColor white ""
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

LogWrite ("{0};{1};{2};{3};{4}" -f "Page Url","Level", "Status", "CheckOut", "CheckedOut By User")

ProcessSubWebs($url)

Write-Host ""
Write-Host -ForegroundColor red "Script End!"


