#!/bin/bash

source log-please.sh

do_stuff(){
    cat /etc/ufw/ufw.conf
    echo "rurururururururururrururururu" > /home/shichi/rurur.txt
    cd /var/log
    pwd
    ls -la
    wget https://google.com
    local folder="/home/shichi/sadfsgl"
    local folder2="/home/shichi"
    if [[ -d $folder ]]
    then
        echo "This folder exists somehow"
    else
        echo "This folder doesn't exist, creating it."
        mkdir $folder
    fi
    if [[ -d $folder2 ]]
    then
        echo "rururu"
    else
        echo "How is this possible?"
    fi
    mkdir /sadf
    ufw allow from any to any 6621
    apt install penis
    pacman -Syyu
}

# Start logging
Log_Open -G

do_stuff

Log_Close