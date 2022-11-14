#!/bin/bash

function check_dependencies {

    commands="top curl rsync netstat bash zip unzip dmidecode hddtemp lm-sensors"
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
        case $distro in
        alpine)
        apk update
        apk add $missing
        ;;
        debian)
        apt-get update
        apt-get install $missing -y
        ;;
        ol)
        dnf install $missing -y
        ;;
        fedora)
        dnf install $missing -y
        ;;
        *)
        echo "[!] Distribution not supported yet. Please report!"
        echo "[#] Following package to manually install:"
        echo "[.] $missing"
        ;;
        esac
    else
        echo "[#] No dependencies need to be installed"
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

    echo "[#] Configuration."
    echo "[.] Enter a domain name for $HOSTNAME"
    read domain
    echo "[.] Enter ssh server name or ip"
    read ssh_server
    echo "[.] Enter ssh server port"
    read ssh_port
    echo "[.] Enter ssh user account"
    read ssh_user

    ssh-keygen -A rsa -f /root/.ssh/id_rsa.pub
    ssh_key=$(cat /root/.ssh/id_rsa.pub)
    echo "[.] Enter password for $ssh_user @ $ssh_server"
    ssh $ssh_user@$ssh_server -p $ssh_port "echo $ssh_key >> .ssh/authorized_keys"

    echo "[#] Ssh keys exchange complete"
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

function help_menu {

    echo -e "SRVCHECK - Server automated check tool...\n"
    echo -e "setup.sh - Script to configure and upgrade srvcheck.\n"
    echo -e "\tUse: setup.sh [OPTIONS]\n"
    echo -e "OPTIONS:"
    echo -e "\tWithout options start an interactive installation of client mode (Upgrade if already installed)\n"
    echo -e "server\tInstall a server instance of srvmonit"
    echo -e "check\tCheck required dependencies and exit"
    echo -e "dependencies\tInstall dependencies and exit"
    echo -e "upgrade\tUpgrade srvcheck and lynis"
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
*)
echo -e "[!] Not recognized option...\n"
help_menu
;;
esac