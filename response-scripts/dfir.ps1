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
netsh trace start persistent=yes capture=yes traceFile=$trace01
#change sleep if you want to gather data for a longer or shorter time frame
sleep 300

netsh trace stop

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
Compress-Archive -Path $trace01, $log01, $log02, $log03, -CompressionLevel Optimal -DestinationPath $location\$env:USERNAME-$(get-date -f yyyy-MM-dd-hh-mm).zip

#####
#Clear logs
#Clear-EventLog Microsoft-Windows-Sysmon/Operational


$bucket = 'blazescan-signatures'
$source = $location
$region = 'us-west-2'

Initialize-AWSDefaultConfiguration -Region $region
 
Set-Location $source
$files = Get-ChildItem '*.bak' | Select-Object -Property Name
try {
   if(Test-S3Bucket -BucketName $bucket) {
      foreach($file in $files) {
         if(!(Get-S3Object -BucketName $bucket -Key $file.Name)) { ## verify if exist
            Write-Host "Copying file : $file "
            Write-S3Object -BucketName $bucket -File $file.Name -Key $file.Name -CannedACLName private
         } 
      }
   } Else {
      Write-Host "The bucket $bucket does not exist."
   }
} catch {
   Write-Host "Error uploading file $file"
}