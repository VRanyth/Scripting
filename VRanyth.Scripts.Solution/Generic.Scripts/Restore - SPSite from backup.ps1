param
(
	[Parameter(Mandatory=$True)]	
	$url = $(Read-Host -Prompt "SiteCollection Url"),
	[Parameter(Mandatory=$True)]	
	$path =  $(Read-Host -Prompt "Full Path Filename(*.bak)")   #C:\bk\site.bak
)

cls
write-host(“## Starting script on Site Collection Url : ” + $url + " ##")
write-host(“")
            
 Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue        

Restore-SPSite $url -Path $path