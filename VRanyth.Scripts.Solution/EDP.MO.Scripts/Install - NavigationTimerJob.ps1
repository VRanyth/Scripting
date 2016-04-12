param
(
	[Parameter(Mandatory=$True)]
	$url = $(Read-Host -Prompt "SiteCollection Url"),

	[Parameter(Mandatory=$True)]
	[boolean]$reinstall =  $(Read-Host -Prompt "Reinstall Feature? (true/false)")
)

if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) 
{
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
}

function Check-SPFeatureActivated
{
    param([string]$Id=$(throw "-Id parameter is required!"),
            [Microsoft.SharePoint.SPFeatureScope]$Scope=$(throw "- Scope parameter is required!"),
            [string]$Url)  
    if($Scope -ne "Farm" -and [string]::IsNullOrEmpty($Url))
    {
        throw "-Url parameter is required for scopes WebApplication,Site and Web"
    }
    $feature=$null
 
	switch($Scope)
	{
		"Farm" { $feature=Get-SPFeature $Id -Farm -erroraction SilentlyContinue}
		"WebApplication" { $feature=Get-SPFeature $Id -WebApplication $Url -erroraction SilentlyContinue}
		"Site" { $feature=Get-SPFeature $Id -Site $Url -erroraction SilentlyContinue}
		"Web" { $feature=Get-SPFeature $Id -Web $Url -erroraction SilentlyContinue}
	}
	$feature -ne $null
}

cls
write-host("")

$web = Get-SPWeb -Identity $url

#Display name of the Timer Job to Run on-demand
$featureName = "Organization Handbook CustomTimerJobs - Navigation"
 
#Get Feature
$feature = Get-SPFeature | Where-Object {$_.Id -eq "c75ebe6d-c457-41a8-a035-82725ed0e6d2"}

$activated = Check-SPFeatureActivated -Id $feature.Id -Scope "Site" -Url $url

write-host(“Activating Feature - ” + $feature.DisplayName)
write-host("")

if($activated)
{
    write-host("Feature already is activated")

    if($reinstall)
    {   
        write-host(“Reactivating Feature - ” + $feature.DisplayName)   
        Disable-SPFeature -Identity $feature.ID -url $url -force -Confirm:$false #-erroraction SilentlyContinue
        Enable-SPFeature -Identity $feature.ID -url $url
    }

    
}
else
{
    Enable-SPFeature -Identity $feature.ID -url $url 
    write-host("Feature activated")
    net stop SPTimerV4
    net start SPTimerV4
}

write-host("")
