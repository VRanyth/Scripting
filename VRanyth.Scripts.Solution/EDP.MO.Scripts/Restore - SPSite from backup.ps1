param
(
	$url = $(Read-Host -Prompt "SiteCollection Url"),
	$path =  $(Read-Host -Prompt "FullPath Backup File(*.bak)")   #C:\bk\site.bak
)

if((Get-PSSnapin | Where {$_.Name -eq "Microsoft.SharePoint.PowerShell"}) -eq $null)             
{            
 Add-PSSnapin Microsoft.SharePoint.PowerShell            
}


Restore-SPSite $url -Path $path