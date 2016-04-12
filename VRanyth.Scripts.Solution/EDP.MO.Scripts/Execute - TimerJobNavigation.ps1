param
(
	[Parameter(Mandatory=$True)]
	$url = $(Read-Host -Prompt "SiteCollection Url")
)

Add-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue

cls
write-host("")

$web = Get-SPWeb -Identity $url

#Display name of the Timer Job to Run on-demand
$TimerJobName = "Organization Handbook Navigation Job"
 
#Get the Timer Job
$TimerJob = Get-SPTimerJob | where { $_.DisplayName -match $TimerJobName}

write-host(“Preparing to run TimerJob - ” + $TimerJob.Name)

#start the timer job
Start-SPTimerJob $TimerJob
write-host("Job queued... Script End")

