param
(
	[Parameter(Mandatory=$True)]
	$url = $(Read-Host -Prompt "SiteCollection Url")
)
Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue

Function LogWrite
{
   Param ([string]$logstring)
   Add-content $Logfile -value $logstring
}

function tryDeleteNode
{
	param($node,$dictionary,$nodeCollection)
	
	$title = $node.Title
    $nodeUrl = $node.Url
    echo "       ->Processing $title"
	
	if(!$dictionary.ContainsKey($title))
	{
		$dictionary.Add($node.Title,$node.Url)
	}
	else
	{ 
        echo "else"
		if($dictionary[$title] -eq $node.Url)
		{			
            if($node.Children.Count -eq 0)
			{
				echo "       -> Deleting Duplicate Node: $title"
				#$nodeCollection.Delete($node)
				$global:didDelete = $true
			    $temp = (get-date).ToString() +";"+ ($site.Url) +";"+ ($title)
			    echo "$temp"
			    LogWrite $($temp)
			}
			else
			{
				echo "       -> Dupe Node $title has children, Skipping"
			}
		}
		else
		{
			echo "       -> Duplicate title $title found, but mismatched link, Skipping"
		}
	}
}

function deleteNodesRecurse
{
	$nodes = @{}
	foreach($node in $quickLaunch)
	{
		$childNodes = @{}
		foreach($child in $node.Children)
		{
			tryDeleteNode -node $child -dictionary $childNodes -nodeCollection $node.Children
		}
		tryDeleteNode -node $node -dictionary $nodes -nodeCollection $quickLaunch
	}
}

function deleteGlobalNodesRecurse
{
	$nodes = @{}
	foreach($node in $gnavNodes)
	{
		$childNodes = @{}
		foreach($child in $node.Children)
		{
			tryDeleteNode -node $child -dictionary $childNodes -nodeCollection $node.Children
		}
		tryDeleteNode -node $node -dictionary $nodes -nodeCollection $gnavNodes
	}
}

$Logfile = "duplicates_log.txt"

$logpath = (Get-Item -Path ".\" -Verbose).FullName + $logpath

$site = Get-SPSite $url
cls
write-host(“## Starting script on Site Collection Url : ” + $site.url + " ##")
write-host("")
write-host(“## If needed, log will be writen on: ” + $logfile + " ##")
write-host("")

foreach ($web in $site.AllWebs)
{
	write-host " -> Site: " $web.URL	
	do
	{
	   $quickLaunch = $web.Navigation.QuickLaunch
	   $global:didDelete = $false

	   deleteNodesRecurse
	   $pub= [Microsoft.SharePoint.Publishing.PublishingWeb]::GetPublishingWeb($web)
	   $gnavNodes = $pub.Navigation.GlobalNavigationNodes;

	   deleteGlobalNodesRecurse
	}
	while($global:didDelete)
	$web.Dispose()
}

$site.Dispose()
