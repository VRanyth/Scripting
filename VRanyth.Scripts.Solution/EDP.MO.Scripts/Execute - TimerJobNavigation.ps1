if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) 
{
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
}
cls
write-host("")
#$url = "http://shp2010dev:22222/"
$url = "http://m01-mo.edp.pt/"
#$url = "http://mo.edp.pt/"


$web = Get-SPWeb -Identity $url

#Display name of the Timer Job to Run on-demand
$TimerJobName = "Organization Handbook Navigation Job"
 
#Get the Timer Job
$TimerJob = Get-SPTimerJob | where { $_.DisplayName -match $TimerJobName}

write-host(“Preparing to run TimerJob - ” + $TimerJob.Name)

#start the timer job
Start-SPTimerJob $TimerJob
write-host("Job queued... Script End")

