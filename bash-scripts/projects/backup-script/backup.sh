#!/bin/bash

# This script is a full system backup for Linux based systems using Rsync and Tar.
# This script should be run as root or with sudo.

# This script assumes that you are backing up your files to a network share.

########=Global Variables=########
now="$(date +"%F_%H:%M:%S")"


########=Error Codes and Message Types=########
<<error_codes
    Errors are set as exit statuses:
    0 = Success!
    1 = General/unknown error.
    2 = Error: Creating the backup directory failed.
error_codes

<<message_types
    Message types are:
    I = Info
    W = Warning
    E = Error
message_types

########=Logging Handler=########
# This function handles log padding.

########=Logging=########
# This function handles logging throughout the script.
<<Usage
    local now="$(date +"%F_%H:%M")"
    exit_status=$?
    if [ ${exit_status} -ne 0 ]; then
        __log "$now Your string here."
    fi
Usage
__log(){
    log_dir="/var/log/backups"
    log_name="backup_$now.log"
    if [[ -d $log_dir ]]
    then
        echo $1 >> $log_dir/$log_name
    else
        mkdir $log_dir
        echo $1 >> $log_dir/$log_name
    fi
}

# Function to perform the backup
__backup(){
    local b_destination="$2"
    local b_source="$1"
    local exit_status=$?
    if [[ -d $destination ]]
    then
        rsync -aAXHv $b_source $b_destination \
        --delete \
        --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"}
        exit_status=$?
        if [ ${exit_status} -ne 0 ]; then
            __log "$now Rsync successfully synced $b_source to $b_destination."
        fi
    else 
        echo "$b_destination does not exist, creating this directory if possible..."
        mkdir $b_destination
        exit_status=$?
        if [ ${exit_status} -ne 0 ]; then
            echo "Error: Creating the backup directory failed!"
            exit "2"
        fi
    fi
}

# Main function
_main(){
    # initialize error log
    __log "Timestamp:            Type:    Message:"
    __log "$(date +"%F_%H:%M:%S") Beginning backup."
    local whichMachine="your-machine-name"
    local backupSource="/"
    local backupDestination="/path/to/share/$whichMachine"
    cd $backupSource
    __backup $backupSource $backupDestination
    local exit_status=$?
    if [ ${exit_status} -ne 0 ]; then
    echo "Error: Creating the backup failed!"
    exit "${exit_status}"
    fi
}

