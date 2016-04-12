param
(
	[Parameter(Mandatory=$True)]
	$url = $(Read-Host -Prompt "SiteCollection Url"),

	[Parameter(Mandatory=$True)]
	[boolean]$reinstall =  $(Read-Host -Prompt "Reinstall Feature? (true/false)")
)

Add-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue

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
 
#Get Feature
$feature = Get-SPFeature | Where-Object {$_.Id -eq "6ed33948-5862-485f-b8bf-1e4935d5df39"}

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
}

write-host("")
