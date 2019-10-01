#Download entire This American LIfe Archives

#Set Protocol Type for Invoke-Webrequest
[System.Net.ServicePointManager]::SecurityProtocol =
    [System.Net.SecurityProtocolType]::Tls12

#Gloabl Vars
$global:lastpercentage = -1
$global:are = New-Object System.Threading.AutoResetEvent $false


While ($i -ne 684){  
    $i++
    $web_url = "https://stream.thisamericanlife.org/$i/$i.mp3"
    $destfolder = "$home\Documents\Podcasts\TAL\"
    $filename = "$destfolder$i.mp3"
    $start_time = Get-Date
    #Web Client
    # (!) Output is buffered to disk -> great speed
    $wc = New-Object System.Net.WebClient
    Register-ObjectEvent -InputObject $wc -EventName DownloadProgressChanged -Action {


    # (!) getting event args
    $percentage = $event.sourceEventArgs.ProgressPercentage
    if($global:lastpercentage -lt $percentage)
    {
        $global:lastpercentage = $percentage
        # stackoverflow.com/questions/3896258
        Write-Host -NoNewline "`r$percentage%"
    }
    }

    Register-ObjectEvent -InputObject $wc -EventName DownloadFileCompleted -Action {
        $global:are.Set()
        Write-Host
    } 
    if (!(Test-Path $destfolder)) {
    New-Item $destfolder -ItemType Directory
    }
    if  (!(Test-Path $filename)) {
            Write-Host "Downloading Episode $i to $filename..."
            $wc.DownloadFileAsync($web_url, $filename)
            while(!$global:are.WaitOne(500)) {}   

    }
    else {
        if (!(Get-Item $filename).length -gt 0kb) {
            Write-Host "Downloading Episode $i to $filename..."
            $wc.DownloadFileAsync($web_url, $filename)
            while(!$global:are.WaitOne(500)) {}
        }
    }
    
    
        
}
