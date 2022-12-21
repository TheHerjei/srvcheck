#!/bin/bash

function check_dependencies {

    commands="top curl rsync bash netstat zip unzip dmidecode hddtemp sensors"
    for i in $commands
    do
        which $i 2>/dev/null
        if [ $? -eq 1 ]
        then
            echo "[!] Missing $i package"
            missing="$missing $i"
        fi
    done

    if [[ $distro == "alpine" ]]
    then
        which coreutils 2>/dev/null
        if [ $? -eq 1 ]
        then
            echo "[!] Missing coreutils package"
            missing="$missing coreutils"
        fi
    fi
    echo "[#] Done"
}

function install {

    if [[ ! $missing == "" ]]
    then
        echo "[!] Please resolve this dependencies, then relaunch setup.sh"
        echo "[#] Following package to manually install:"
        echo "[.] $missing"
        exit 0
    else
        echo "[#] Dependencies OK!"
    fi

    echo "[#] Done"
}

function upg_lynis {

    if [ -e /opt/lynis ]
    then
        echo "[#] Lynis already exist. Upgrading."
    else
        echo "[#] Lynis first installation. Consider adding a default.prf"
        mkdir /opt/lynis
    fi

    wget -O lynis.zip "https://github.com/CISOfy/lynis/archive/refs/heads/master.zip"
    unzip lynis.zip
    rsync -a lynis-master/ /opt/lynis/
    rm -rf lynis.zip
    rm -rf lynis-master

    echo "[#] Done"

}

function upg_srvcheck {

    if [ -e /opt/srvcheck ]
    then
        echo "[#] Srvcheck already exist. Upgrading."
        srvcheck=1
        cat /opt/srvcheck/srvcheck | grep 'rsync.*-zav' > srvsync.save
        cat /opt/srvcheck/srvcheck | grep 'bkpPartition.*-zav' > srvbkpsto.save
    else
        echo "[#] Srvcheck first installation."
        mkdir /opt/srvcheck
    fi

    wget -O srvcheck.zip "https://github.com/TheHerjei/srvcheck/archive/refs/heads/main.zip"
    unzip srvcheck.zip
    rsync -a srvcheck-main/ /opt/srvcheck/
    rm -rf srvcheck.zip
    rm -rf srvcheck-main
    
    echo "[#] Done"
}

function config {
    if [ $srvcheck -eq 1 ]
    then
        echo "[#] Restoring previous configuration..."
        c=$(cat srvsync.save)
        sed -i "s~^rsync.*~$c~" /opt/srvcheck/srvcheck
        c=$(cat srvbkpsto.save)
        sed -i "s~^bkpPartition.*~$c~" /opt/srvcheck/srvcheck
        echo "[#] Done!"
    else
        echo "[#] Configuration."
        echo "[.] Enter a domain name for $HOSTNAME"
        read domain
        echo "[.] Enter ssh server name or ip"
        read ssh_server
        echo "[.] Enter ssh server port"
        read ssh_port
        echo "[.] Enter ssh user account"
        read ssh_user

        ssh-keygen -t rsa -f /root/.ssh/id_rsa.pub
        echo "[.] Enter password for $ssh_user @ $ssh_server"
        ssh-copy-id $ssh_user@$ssh_server -p $ssh_port

        if [ $? -eq 0 ]
        then
            echo "[#] Ssh keys exchange complete"
        else
            echo "[!] Connection error, manual ssh exchange needed!"
        fi

        sed -i "s/CHANGEPORT/$ssh_port/" /opt/srvcheck/srvcheck
        sed -i "s/CHANGEUSER/$ssh_user/" /opt/srvcheck/srvcheck
        sed -i "s/CHANGESERVER/$ssh_server/" /opt/srvcheck/srvcheck
        sed -i "s/CHANGEDOMAIN/$domain/" /opt/srvcheck/srvcheck

        echo "[.] Enter restic repository path (enter for skipping)"
        read resticpath
        if [[ ! $resticpath == "" ]]
        then
            echo "[.] Enter password for restic repo"
            read resticpwd
            sed -i "s/CHANGERESTICPASSWORD/$resticpwd/" /opt/srvcheck/srvcheck
            sed -i "s~CHANGERESTICREPOPATH~$resticpath~" /opt/srvcheck/srvcheck
            echo "[#] Restic configured..."
        else
            sed -i 's/CHANGERESTICPASSWORD/""/' /opt/srvcheck/srvcheck
        fi

        echo "[.] Enter backup partition (enter for default /mnt/bkp)"
        read bkpPartition
        if [[ $bkpPartition == "" ]]
        then
            sed -i "s~^bkpPartition.*~bkpPartition=/mnt/bkp~" /opt/srvcheck/srvcheck
        else
            sed -i "s~^bkpPartition.*~bkpPartition=$bkpPartition~" /opt/srvcheck/srvcheck
        fi

        echo "[.] Choose srvcheck schedule"
        echo "[.] daily weekly monthly"
        read freq

        case $freq in
        daily)
        if [[ $distro == alpine ]]
        then
        ln -s /opt/srvcheck/srvcheck /etc/periodic/$freq/srvcheck
        else
        ln -s /opt/srvcheck/srvcheck /etc/cron.$freq/srvcheck
        fi
        ;;
        weekly)
        if [[ $distro == alpine ]]
        then
        ln -s /opt/srvcheck/srvcheck /etc/periodic/$freq/srvcheck
        else
        ln -s /opt/srvcheck/srvcheck /etc/cron.$freq/srvcheck
        fi
        ;;
        monthly)
        if [[ $distro == alpine ]]
        then
        ln -s /opt/srvcheck/srvcheck /etc/periodic/$freq/srvcheck
        else
        ln -s /opt/srvcheck/srvcheck /etc/cron.$freq/srvcheck
        fi
        ;;
        *)
        echo "[!] Unrecognised option"
        echo "[#] Auto choosing to daily..."
        if [[ $distro == alpine ]]
        then
        ln -s /opt/srvcheck/srvcheck /etc/periodic/daily/srvcheck
        else
        ln -s /opt/srvcheck/srvcheck /etc/cron.daily/srvcheck
        fi
        ;;
        esac

        echo "[#] Done"
    fi    
}

function config_srv {
    echo "[#] Configuring srvmonit to run daily..."
    if [[ $distro == alpine ]]
    then
    ln -s /opt/srvcheck/srvmonit /etc/periodic/daily/srvmonit
    else
    ln -s /opt/srvcheck/srvmonit /etc/cron.daily/srvmonit
    fi
}

function remove {

    echo "[!] Removing srvcheck..."
    echo "[.] Remove /opt/srvcheck folder? (y/n)"
    read choice
    case $choice in
    y)
    echo "[#] Removing..."
    rm -rf /opt/srvcheck
    find /etc/cron.* -name "srvcheck" -type l -delete
    find /etc/periodic/* -name "srvcheck" -type l -delete
    echo "[#] Done"
    ;;
    *)
    echo "[#] Skipping"
    ;;
    esac

    echo "[.] Remove /opt/lynis folder? (y/n)"
    read choice
    case $choice in
    y)
    echo "[#] Removing..."
    rm -rf /opt/lynis
    echo "[#] Done"
    ;;
    *)
    echo "[#] Skipping"
    ;;
    esac

    echo "[.] Remove /var/log/srvcheck folder? (y/n)"
    read choice
    case $choice in
    y)
    echo "[#] Removing..."
    rm -rf /var/log/srvcheck
    if [[ $distro == alpine ]]
    then
        find /etc/periodic/ -maxdepth 1 -follow -type l -delete
    else
        find /etc/cron.* -maxdepth 2 -follow -type l -delete
    fi

    echo "[#] Done"
    ;;
    *)
    echo "[#] Skipping"
    ;;
    esac

    echo "[.] Remove lynis.log and lynis.dat files? (y/n)"
    read choice
    case $choice in
    y)
    echo "[#] Removing..."
    rm -rf /var/log/lynis.log
    rm -rf /var/log/lynis.dat
    echo "[#] Done"
    ;;
    *)
    echo "[#] Skipping"
    ;;
    esac

}

function backup {
    F="$(date +%Y$%m%d)-srvcheck.bkp"
    touch $F
    echo "[#] Backupping configs..."
    cat /opt/srvcheck/srvcheck | grep 'rsync.*-zav' >> $F
    cat /opt/srvcheck/srvcheck | grep 'bkpPartition.*-zav' >> $F

    echo "[#] Done"
    exit 0
}

function restore {
    echo "[!] Not yet implemented..."
    exit 0
}

function help_menu {

    echo -e "SRVCHECK - Server automated check tool...\n"
    echo -e "setup.sh - Script to configure and upgrade srvcheck.\n"
    echo -e "\tUse: setup.sh [OPTIONS]\n"
    echo -e "OPTIONS:"
    echo -e "\tWithout options start an interactive installation of client mode (Upgrade if already installed)\n"
    echo -e "server\tInstall a server instance of srvmonit"
    echo -e "silent\tClient installation with default configs. Require manual configuration or restore of previous conf."
    echo -e "check\tCheck required dependencies and exit"
    echo -e "dependencies\tInstall dependencies and exit"
    echo -e "upgrade\tUpgrade srvcheck and lynis"
    echo -e "backup\tStores configs in text file and exit"
    echo -e "restore\tRestore conf from a file"
    echo -e "remove\tRemove srcheck and lynis interactively"
    echo -e "help\tDisplay help and exit\n"

}

# Root permission check
p=$(id | awk '{ print $1 }')
if [ $p != "uid=0(root)" ]
then
    echo "[!] Critical, no root permission!"
    echo "[#] exiting..."
    exit 0
fi

# Variable initialization
missing=""
srvcheck=0
distro=$(cat /etc/os-release | grep '^ID=.*' | sed s/ID=//)

case $1 in
help)
help_menu
;;
check)
check_dependencies
;;
install)
check_dependencies
install
;;
silent)
check_dependencies
install
upg_lynis
upg_srvcheck
;;
remove)
remove
;;
server)
check_dependencies
install
upg_srvcheck
upg_lynis
config_srv
;;
"")
check_dependencies
install
upg_lynis
upg_srvcheck
config
;;
upgrade)
upg_lynis
upg_srvcheck
config
;;
backup)
backup
;;
restore)
restore
;;
*)
echo -e "[!] Not recognized option...\n"
help_menu
;;
esac