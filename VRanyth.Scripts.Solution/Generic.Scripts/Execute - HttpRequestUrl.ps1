param
(
	$url = $(Read-Host -Prompt "Url"),
    $Times = $(Read-Host -Prompt "Retry Count")
)
cls
$i = 0
$average = 0
While ($i -lt $Times)
{
    $Request = New-Object System.Net.WebClient
    $Request.UseDefaultCredentials = $true
    $Start = Get-Date
    $PageRequest = $Request.DownloadString($URL)
    $TimeTaken = ((Get-Date) - $Start).TotalMilliseconds 
    $Request.Dispose()
    $ts =  [timespan]::FromMilliseconds($TimeTaken)
    
    Write-Host "Request " ($i + 1) " >> "  $ts.TotalSeconds " seconds" -ForegroundColor Green
    $average += $ts.TotalSeconds
    $i ++
}

Write-Host " "
Write-Host "Average Time in Seconds: "  ($average/$i) " seconds." -ForegroundColor DarkRed