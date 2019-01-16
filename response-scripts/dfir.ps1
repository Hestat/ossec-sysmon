$trace01="C:\Program Files (x86)\ossec-agent\logs\trace001$(get-date -f yyyy-MM-dd-hh-mm).etl"
$pcap01="C:\Program Files (x86)\ossec-agent\logs\trace$(get-date -f yyyy-MM-dd-hh-mm).cap"
$log01="C:\Program Files (x86)\ossec-agent\logs\summary$(get-date -f yyyy-MM-dd-hh-mm).log"
$log02="C:\Program Files (x86)\ossec-agent\logs\sysmon$(get-date -f yyyy-MM-dd-hh-mm).evtx"
$log03="C:\Program Files (x86)\ossec-agent\logs\defender$(get-date -f yyyy-MM-dd-hh-mm).evtx"
$startdate="get-date"
$comp="hostname"


quser.exe > $log01
gdr -PSProvider 'Filesystem' >> $log01
ps >> $log01


netsh trace start persistent=yes capture=yes traceFile=$trace01

sleep 300

netsh trace stop

$s = New-PefTraceSession -Path $pcap01 -SaveOnStop
$s | Add-PefMessageProvider -Provider $trace01
$s | Start-PefTraceSession

wevtutil.exe epl Microsoft-Windows-Sysmon/Operational $log02
wevtutil.exe epl "Microsoft-Windows-Windows Defender/Operational" $log03