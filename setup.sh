#!/bin/bash

function display_print () {
    local N=''
    local R=''

    local width=$W
    local height=$H

    local empty_line='\n'
    local edge='-'

    while [ $width -gt 2 ]
    do
        edge=$edge'='
        let width--
    done
    edge=$edge'-'

    local w=$(expr $W - ${#S})
    w=$(expr $w / 2)
    while [ $w -gt 2  ]
    do
        N=$N' '
        let w--
    done

    w=$(expr $W - ${#N} - ${#S})
    while [ $w -gt 2 ]
    do
        R=$R' '
        let w--
    done

    clear -x
    echo $edge
    echo -en $empty_line
    echo "|$N$S$R|"
    if [ ${#E} -gt 0 ]
    then
        N=''
        R=''
        w=0
        w=$(expr $W - ${#E})
        w=$(expr $w / 2)
        while [ $w -gt 2  ]
        do
            N=$N' '
            let w--
        done

        w=$(expr $W - ${#N} - ${#E})
        while [ $w -gt 2 ]
        do
            R=$R' '
            let w--
        done
        echo "|$N$E$R|"
    fi
    echo -en $empty_line
    echo -e $edge"\n"
}

function progress_bar {
    local width=$(tput cols)
    local riempi=$(( width - ${#message} - 20 ))
    local spazi=''
    
    while [ $riempi -gt 1 ]
    do
        spazi=$spazi' '
        let riempi--
    done

    case $percentage in
    0)
    echo -en "# $message #$spazi ----------   0%\r"
    ;;
    10)
    echo -en "# $message #$spazi #---------  10%\r"
    ;;
    20)
    echo -en "# $message #$spazi ##--------  20%\r"
    ;;
    30)
    echo -en "# $message #$spazi ###-------  30%\r"
    ;;
    40)
    echo -en "# $message #$spazi ####------  40%\r"
    ;;
    50)
    echo -en "# $message #$spazi #####-----  50%\r"
    ;;
    60)
    echo -en "# $message #$spazi ######----  60%\r"
    ;;
    70)
    echo -en "# $message #$spazi #######---  70%\r"
    ;;
    80)
    echo -en "# $message #$spazi ########--  80%\r"
    ;;
    90)
    echo -en "# $message #$spazi #########-  90%\r"
    ;;
    100)
    echo -en "# $message #$spazi ########## 100%\r"
    ;;
    *)
    echo -en "# $message #$spazi ########## 100%\r"
    ;;
    esac
}

W=$(tput cols)

S="Installazione srvcheck in corso..."
display_print

p=$(id | awk '{ print $1 }')
if [ $p != "uid=0(root)" ]
then
    E=" Mancano privilegi di root! [KO]"
    display_print
    exit 0
fi

# Check dependencies
message="Controllo dipendenze"
percentage=0
progress_bar

distro=$(cat /etc/os-release | grep '^ID.*' | sed s/ID=//)
missing=0
if [ ! -e /usr/bin/top ]
then
    E="# top [KO]"
    display_print
    let missing++
fi

if [ ! -e /usr/bin/curl ]
then
    E= "# curl [KO]"
    display_print
    let missing++
fi

if [ ! -e /usr/bin/rsync ]
then
    E="# rsync [KO]"
    display_print
    let missing++
fi

if [ ! -e /opt/lynis/lynis ]
then
    E="# lynis [KO]"
    display_print
    let missing++
fi

if [ ! -e /usr/bin/netstat ]
then
    if [ ! -e /bin/netstat ]
    then
        E="# netstat [KO]"
        display_print
        let missing++
    fi
fi

message="Controllo dipendenze"
percentage=20
progress_bar

if [ ! -e /usr/bin/restic ]
then
    E="# restic [KO]"
    display_print
    let missing++
fi

if [[ $distro = 'alpine' ]]
then
    if [ ! -e /usr/bin/coreutils ]
    then
        E="# coreutils [KO]"
        display_print
        let missing++
    fi
fi

if [ ! -e /usr/bin/git ]
then
    E="# git [KO]"
    display_print
    let missing++
fi

message="Risolvo dipendenze"
percentage=50
progress_bar

if [ $missing -gt 0 ]
then
    case distro in
    alpine)
    apk update 2&1> /dev/null
    message="Risolvo dipendenze"
    percentage=70
    progress_bar
    apk add git restic rsync coreutils iputils curl top vim > /dev/null 2>&1
    ;;
    debian)
    apt update 2&1> /dev/null
    message="Risolvo dipendenze"
    percentage=70
    progress_bar
    apt install restic git net-tools curl rsync top vim -y > /dev/null 2>&1
    ;;
    *)
    E="# Distribuzione non supportata!"
    display_print
    ;;
    esac
    message="Risolvo dipendenze"
    percentage=100
    progress_bar
fi

message="Scarico Repositories"
percentage=0
progress_bar

if [ ! -e /opt/lynis/lynis ]
then
    cd /opt
    git clone https://github.com/CISOfy/lynis.git > /dev/null 2>&1
fi

message="Scarico Repositories"
percentage=50
progress_bar

if [ ! -e /opt/srvcheck/srvcheck ]
then
    cd /opt
    git clone https://github.com/theherjei/srvcheck.git > /dev/null 2>&1
fi

message="Scarico Repositories"
percentage=100
progress_bar

if [ ! -e /usr/bin/srvcheck ]
then
    ln -s /opt/srvcheck /usr/bin/srvcheck > /dev/null 2>&1
fi

S="Configurazione srvcheck..."
E="A quale dominio [tag] appartiene il server?"
display_print

message="Configurazione..."
percentage=10
progress_bar
echo -e "\n\n"
read domain

S="Configurazione srvcheck..."
E="Inserire utente del log server"
display_print

message="Configurazione..."
percentage=30
progress_bar
echo -e "\n\n"
read ssh_user

S="Configurazione srvcheck..."
E="Inserire indirizzo log server"
display_print

message="Configurazione..."
percentage=40
progress_bar
echo -e "\n\n"
read ssh_server

S="Configurazione srvcheck..."
E="Inserire porta ssh di $ssh_server"
display_print

message="Configurazione..."
percentage=50
progress_bar
echo -e "\n\n"
read ssh_port


S="Configurazione srvcheck..."
E="Scambio chiavi..."
display_print

message="Scambio chiavi SSH..."
percentage=60
progress_bar

ssh-keygen -A rsa -f /root/.ssh/id_rsa.pub

S="Configurazione srvcheck..."
E="Scambio chiavi..."
display_print
percentage=70
progress_bar

ssh_key=$(cat /root/.ssh/id_rsa.pub)
ssh $ssh_user@$ssh_server -p $ssh_port "echo $ssh_key >> .ssh/authorized_keys" > /dev/null 2>&1

S="Configurazione srvcheck..."
E="Aggiorno script srvchk..."
display_print
message="Concludo..."
percentage=90
progress_bar

payload="rsync -zav --rsh=\"ssh -p $ssh_port\" /var/log/srvcheck/ $ssh_user@$ssh_server:/var/log/srvcheck/$domain/\$HOSTNAME/"
echo -e "\n$payload" >> /opt/srvcheck/srvcheck
cat /opt/srvcheck/srvcheck |tail -n 1
sleep 5s

S="Configurazione srvcheck..."
E="# Finito!!! #"
display_print
message="Fatto!"
percentage=100
progress_bar
echo -e "\n"