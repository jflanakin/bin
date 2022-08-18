#!/bin/bash
# This is a library I built to learn how to use libraries in bash.

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
		;;
			esac
}

# Function which adds your user to the sudo group. If the user doesn't exist, call the create_User function.
modify_user() {
	local username=$1
	# Checks to verify if user exists. Returns 0 if the user exists, returns 1 if the user does NOT exist.
	local user_exists=$(id -u $username > /dev/null 2>&1; echo $?)
	if [[ $user_exists -eq 0 ]]
	then
		echo "Adding $username to the sudo group..."
		sleep 2
		/usr/sbin/usermod -aG sudo $username
	else
		until create_user $username ; do : ; done
	fi
}

# Function to update and install necessary software
install_essential() {
	# Add non-free and contrib repositories
	cp /etc/apt/sources.list /etc/apt/sources.list.bak
	sed -i 's/bullseye main/bullseye main contrib non-free/' /etc/apt/sources.list
	apt -y update
	apt -y install intel-microcode build-essential dkms linux-headers-$(uname -r)
	apt -y install sudo vim open-vm-tools openssh-server ufw molly-guard fail2ban dnsutils net-tools gnupg2 apt-transport-https
	apt -y install gcc make check git tar gzip wget curl rsync nmon tmux neofetch zsh bpytop
	# install zerotier (gpg method from here: https://www.zerotier.com/download/)
	curl -s 'https://raw.githubusercontent.com/zerotier/ZeroTierOne/master/doc/contact%40zerotier.com.gpg' | gpg --import && \
	if z=$(curl -s 'https://install.zerotier.com/' | gpg); then echo "$z" | bash; fi
}

# Modify SSH config
modify_ssh(){
	cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
	sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
	sed -i '/^#MaxSessions 10.*/a Protocol 2' /etc/ssh/sshd_config
	sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
	sed -i "/^Protocol 2.*/a AllowUsers $YOURUSER" /etc/ssh/sshd_config
}

# Create and modify fail2ban config
modify_fail2ban(){
	local username=$1
	cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
	sed -i 's/send = root@<fq-hostname>/send = root@localhost/g' /etc/fail2ban/jail.local
	sed -i "s/destemail = root@localhost/destemail = $username@localhost/g" /etc/fail2ban/jail.local
	cat <<EOF | tee /etc/fail2ban/jail.d/sshd.conf
[sshd]
enabled = true
port = 22
mode = aggressive
EOF
}

# Create and configure UFW
modify_ufw(){
	# Default UFW rules are to deny all ingress.
	# Creates basic UFW rule for SSH
	echo "Configuring UFW to allow SSH access, then reloading UFW..."
	sleep 1
	/usr/sbin/ufw allow ssh
	/usr/sbin/ufw enable
	/usr/sbin/ufw reload
}