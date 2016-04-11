cls
$process = "vssphost4"
$dir = "C:\Users\devadmin\AppData\Local\assembly\dl3"

if((get-process $process -ea SilentlyContinue) -eq $Null){ 
        echo "vssphost4 is Not Running"
        echo ""
}

else{ 
    echo "vssphost4 is Running"
    echo ""
    Stop-Process -processname "vssphost4"
    echo $process "was killed"
 }

if(Test-Path dir)
{
    Remove-Item $dir
    echo ""
    echo "%AppData%assembly was erased"
    echo ""
}
else
{
    echo "%AppData%assembly was already clean"
    echo ""
}