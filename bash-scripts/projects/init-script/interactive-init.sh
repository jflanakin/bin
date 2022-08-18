#!/bin/bash
# This project assumes Debian 11 and an Intel Based CPU or a hypervisor on an Intel based platform.
# This prepares a server for nearly any general purpose use.

# set -e

# Function to create an individual user, give them sudo privileges, and set a password for them.
# Usage: create_User username
create_user() {
	local username=$1
	local verify_creation=""
	echo "$username does not exist."
	read -p "Do you want to create the user $username? [Y/N]: " verify_creation
	case "$verify_creation" in
		Y|y)
			echo "$username will be created with sudo privileges."
			/usr/sbin/useradd -m -U -s /usr/bin/zsh -G sudo $username
			/usr/bin/passwd $username
			return 0
		;;
		N|n)
			echo "$username will not be created."
			return 0
		;;
		*)
			echo "Please answer with Y, y, N, or n only."
			return 1
	esac
}

# Function which adds your user to the sudo group. If the user doesn't exist, call the create_User function.
modify_user() {
	local USERNAME=""
	read -p "What is your username? " USERNAME
	# Checks to verify if user exists. Returns 0 if the user exists, returns 1 if the user does NOT exist.
	local user_exists=$(id -u $USERNAME > /dev/null 2>&1; echo $?)
	if [[ user_exists -eq 0 ]]
	then
		echo "Adding $USERNAME to the sudo group..."
		sleep 2
		/usr/sbin/usermod -aG sudo $user
	else
		until create_user $USERNAME ; do : ; done
	fi
}
	
# Update and install necessary software
install_Essential() {
	# Add non-free and contrib repositories
	cp /etc/apt/sources.list /etc/apt/sources.list.bak
	sed -i 's/bullseye main/bullseye main contrib non-free/' /etc/apt/sources.list
	# Install necessary software
	# Sleep commands help prevent issues with apt but they aren't strictly necessary if you really need those three seconds.
	apt -y update
	sleep 1
	apt -y install intel-microcode build-essential dkms linux-headers-$(uname -r)
	sleep 1
	apt -y install sudo vim open-vm-tools openssh-server ufw molly-guard fail2ban dnsutils net-tools gnupg2 apt-transport-https
	sleep 1
	apt -y install gcc make check git tar gzip wget curl rsync nmon tmux neofetch zsh bpytop
}

function installExtra() {
	# install zerotier
	curl -s 'https://raw.githubusercontent.com/zerotier/ZeroTierOne/master/doc/contact%40zerotier.com.gpg' | gpg --import && \
	if z=$(curl -s 'https://install.zerotier.com/' | gpg); then echo "$z" | sudo bash; fi
	
	#test if running bash as a different user works
	local RUNAS="sudo -u shichi"
	
	echo 1: $USER
	
	#Runs bash with commands between '_' as nobody if possible
	$RUNAS bash<<_
sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
_
}