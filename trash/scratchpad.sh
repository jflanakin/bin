#!/bin/bash


__if_exists(){
    dir="$1"

    if [[ -e $dir ]] || [[ $dir = "" ]]
    then
        echo "rururu"
    else
        echo "no rururu"
    fi
}

__if_exists

whoiam=$(whoami)
echo $whoiam

printf "rururu\n"

__save(){
	local name=$1
	local toSave=$2
	local path=$3
    printf "\n"
	printf "${name} is saved.\n"
}

__save "penis vagina butthole"