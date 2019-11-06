#######
#Script to collect important logs and forensic triage information from a compromised system
#
#
#
#Set paths and log variables
$location="C:\Program Files (x86)\ossec-agent\logs\"
$trace01="C:\Program Files (x86)\ossec-agent\logs\trace001$(get-date -f yyyy-MM-dd-hh-mm).etl"
$pcap01="C:\Program Files (x86)\ossec-agent\logs\trace$(get-date -f yyyy-MM-dd-hh-mm).cap"
$log01="C:\Program Files (x86)\ossec-agent\logs\summary$(get-date -f yyyy-MM-dd-hh-mm).log"
$log02="C:\Program Files (x86)\ossec-agent\logs\sysmon$(get-date -f yyyy-MM-dd-hh-mm).evtx"
$log03="C:\Program Files (x86)\ossec-agent\logs\defender$(get-date -f yyyy-MM-dd-hh-mm).evtx"
$startdate="get-date"
$comp="hostname"

#####
#gather basic data on the system
quser.exe > $log01
gdr -PSProvider 'Filesystem' >> $log01
ps >> $log01

#####
#Collect 5 minutes of network activity (will be in microsoft event trace format, use the microsoft message analyzer to read)
#Or use the commented out section below to move to pcap
#netsh trace start persistent=yes capture=yes traceFile=$trace01
#change sleep if you want to gather data for a longer or shorter time frame
#sleep 300

#netsh trace stop

#need microsoft message analyzer for this
#$s = New-PefTraceSession -Path $pcap01 -SaveOnStop
#$s | Add-PefMessageProvider -Provider $trace01
#$s | Start-PefTraceSession

#####
#Dump pertinent logs
wevtutil.exe epl Microsoft-Windows-Sysmon/Operational $log02
wevtutil.exe epl "Microsoft-Windows-Windows Defender/Operational" $log03

####
#Zip up our collected data
Compress-Archive -Path $log01, $log02, $log03 -CompressionLevel Optimal -DestinationPath $location\$env:USERNAME-$(get-date -f yyyy-MM-dd-hh-mm).zip
$TargetFilePath="/$env:USERNAME-$(get-date -f yyyy-MM-dd-hh-mm).zip"
$SourceFilePath="$location\$env:USERNAME-$(get-date -f yyyy-MM-dd-hh-mm).zip"
$arg = '{ "path": "' + $TargetFilePath + '", "mode": "add", "autorename": true, "mute": false }'
$authorization = "Bearer " + "enter_token"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", $authorization)
$headers.Add("Dropbox-API-Arg", $arg)
$headers.Add("Content-Type", 'application/octet-stream')
Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile $SourceFilePath -Headers $headers

#####
#Clear logs
#Clear-EventLog Microsoft-Windows-Sysmon/Operational
#rm $SourceFilePath
#rm $log01
#rm $log02
#rm $log03
