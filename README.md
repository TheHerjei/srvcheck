# Server Check

**srvcheck:** - Script to run on servers or Workstations to automatically run checks system wide.
The output in cvs format is easy to read and parse or filter as needed.

**setup.sh** - Script to easily install, configure or remove srvcheck. At this time it can configure: package dependencies, ssh-key access for log server, automation scheduling, domain name (for log server archiviation).
*FUTURE IMPLEMENTATIONS: choose server or client installation, config rsync client or rsyncd.*

**srvmonit** - Service that act as "server" for several instance of srvcheck. It manage the report retention policy, parse the errors and generate a "general report", with enphasys on critical errors and warnings for each instance of srvcheck.
  It need SSH server with rsa key authentication enabled.


## Installation

**Client mode:**
run on terminal as root user:
`wget -O setup.sh "https://raw.githubusercontent.com/TheHerjei/srvcheck/main/setup.sh";chmod +x setup.sh;sh setup.sh`

and follow onscreen instructions.

**Server mode:**
run on terminal as root user:
`wget -O setup.sh "https://raw.githubusercontent.com/TheHerjei/srvcheck/main/setup.sh";chmod +x setup.sh;sh setup.sh server`

*Note:*
    Make sure to configure your Log server to be reachable via ssh (for over the internet application you must run srvmonit on VPS or use port-forwarding).

## Srvcheck Output scheme:

*Output report scheme:*
CheckID;ResultCode;Timestamp;Notes

*ResultCode:*
0 = No errors
1 = Non critical, warning
2 = Critical, not working

|Implemented|CheckID|Description|
|-----------|-------|-----------|
|OK|SLF001|Check root permission|
|OK|SLF002|Check srvcheck dependencies|
|OK|SLF002|Check report dir existing|
|OK|SLF004|Initialize report file|
|OK|SYS001|Check linux distro|
|OK|SYS002|Check machine HOSTNAME|
|OK|SYS003|Check kernel version|
|OK|SYS004|Check uptime|
|OK|SYS005|Check date/time|
|OK|SYS006|Check VM/container|
|OK|SYS007|Check root filesystem|
|OK|SYS008|Check CPU Temp|
|TODO|SYS009|Check GPU Temp|
|OK|SYS010|Check Disks Temp|
|OK|STO001|Check root storage usage|
|OK|STO002|Check /home storage usage|
|OK|STO003|Check LVMs Usage|
|OK|STO004|Check S.M.A.R.T. health|
|OK|STO005|Check ZFS health|
|OK|MEM001|Check SYS total memory|
|OK|MEM002|Check free available memory|
|OK|MEM003|Check memory usage percentage|
|OK|MEM004|Check higher memory consumpting process|
|OK|CPU001|Check CPU model|
|OK|CPU002|Check CPU Threads|
|OK|CPU003|Check CPU Usage|
|OK|CPU004|Check higher CPU consumpting process|
|TODO|SVC001|Check init system|
|OK|SVC002|Check stopped/failed services|
|OK|VME001|Check qemu exist|
|OK|VME002|Check lxc exist|
|TODO|VME003|Check lxd exist|
|OK|VME004|Check qemu vm stopped|
|OK|VME005|Check lxc container stopped|
|TODO|VME009|Check lxd container stopped|
|TODO|VME010|Check docker exist|
|TODO|VME012|Check docker containers stopped|
|OK|BKP001|Check Restic backup exist|
|OK|BKP002|Check exist & usage of /mnt/bkp|
|OK|BKP003|Check last backup time/date|
|OK|BKP004|Check restic snapshots count|
|OK|BKP005|Check difference between last 2 restic backups|
|OK|NET001|Check internet connection|
|OK|NET002|Check dns|
|TODO|NET003|Check ESTABLISHED connections|
|TODO|NET004|Check LISTENING connections|
|OK|UPG001|Check update availability|
|OK|SEC001|Check Lynis folder exist|
|OK|SEC002|Launch Lynis audit system|
|OK|SEC003|Parse Lynis warnings|
|OK|SEC004|Parse Lynis suggestions|
|OK|SYN001|Log files retention|
|OK|SYN002|Rsync log files|s