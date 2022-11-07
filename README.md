# Server Check

**Objective:**
A Script to run on servers or Workstations to automatically run checks system wide.
The script outputs in cvs format to be easily readable and processed or filtered as needed.

## Installation

run on terminal as root user:
`wget -O setup.sh "https://raw.githubusercontent.com/TheHerjei/srvcheck/main/setup.sh"`

then run:
`chmod +x setup.sh`

lastly:
`./setup.sh`

and follow onscreen instructions.

## Output scheme:

*Output report scheme:*
CheckID;ResultCode;Timestamp;Notes

*ResultCode:*
0 = No errors
1 = Non critical, warning
2 = Critical, not working

|Implemented|CheckID|Description|
|-----------|-------|-----------|
|V |SLF001|Check root permission|
|V |SLF002|Check srvcheck dependencies|
|V |SLF002|Check report dir existing|
|V |SLF004|Initialize report file|
|V |SYS001|Check linux distro|
|V |SYS002|Check machine HOSTNAME|
|V |SYS003|Check kernel version|
|V |SYS004|Check uptime|
|V |SYS005|Check date/time|
|V |SYS006|Check VM/container|
|V |SYS007|Check root filesystem|
|V |SYS008|Check CPU Temp|
|TODO|SYS009|Check GPU Temp|
|V |SYS010|Check Disks Temp|
|V |STO001|Check root storage usage|
|V |STO002|Check /home storage usage|
|V |STO003|Check LVMs Usage|
|V |STO004|Check S.M.A.R.T. health|
|V |STO005|Check ZFS health|
|V |MEM001|Check SYS total memory|
|V |MEM002|Check free available memory|
|V |MEM003|Check memory usage percentage|
|V |MEM004|Check higher memory consumpting process|
|TODO|CPU001|Check CPU model|
|TODO|CPU002|Check CPU Threads|
|V |CPU003|Check CPU Usage|
|V |CPU004|Check higher CPU consumpting process|
|TODO|SVC001|Check init system|
|V |SVC002|Check stopped/failed services|
|V |VME001|Check qemu exist|
|V |VME002|Check lxc exist|
|TODO|VME003|Check lxd exist|
|V |VME004|Check qemu vm stopped|
|V |VME005|Check lxc container stopped|
|TODO|VME009|Check lxd container stopped|
|TODO|VME010|Check docker exist|
|TODO|VME012|Check docker containers stopped|
|V |BKP001|Check Restic backup exist|
|V |BKP002|Check exist & usage of /mnt/bkp|
|V |BKP003|Check last backup time/date|
|V |BKP004|Check restic snapshots count|
|V |BKP005|Check difference between last 2 restic backups|
|V |NET001|Check internet connection|
|V |NET002|Check dns|
|TODO|NET003|Check ESTABLISHED connections|
|TODO|NET004|Check LISTENING connections|
|V |UPG001|Check update availability|
|V |SEC001|Check Lynis folder exist|
|V |SEC002|Launch Lynis audit system|
|V |SEC003|Parse Lynis warnings|
|V |SEC004|Parse Lynis suggestions|
|V |SYN001|Rsync log files|