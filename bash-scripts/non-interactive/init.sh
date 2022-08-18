#!/bin/bash
# This project assumes Debian 11 and an Intel Based CPU or a hypervisor on an Intel based platform.
# This prepares a server for nearly any general purpose use.

# Find and replace $YOURUSER with your username. 
# Setting that value as a variable has had... mixed results, so just suffer
#   editing this script once you download it to change the name.

# Verify user is running as root or with sudo
if [ "$EUID" -ne 0 ]
then echo "Please run as root"
	exit
else
	# Add non-free and contrib repositories
	cp /etc/apt/sources.list /etc/apt/sources.list.bak
	sed -i 's/bullseye main/bullseye main contrib non-free/' /etc/apt/sources.list
	
	# install necessary software
	apt -y update
	apt -y install intel-microcode build-essential dkms linux-headers-$(uname -r)
	apt -y install sudo vim open-vm-tools openssh-server ufw molly-guard fail2ban dnsutils net-tools gnupg2 apt-transport-https
	apt -y install gcc make check git tar gzip wget curl rsync nmon htop tmux neofetch zsh bpytop
	
	# install zerotier
	curl -s 'https://raw.githubusercontent.com/zerotier/ZeroTierOne/master/doc/contact%40zerotier.com.gpg' | gpg --import && \
	if z=$(curl -s 'https://install.zerotier.com/' | gpg); then echo "$z" | sudo bash; fi
	
	# Modify SSH config
	cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
	sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
	sed -i '/^#MaxSessions 10.*/a Protocol 2' /etc/ssh/sshd_config
	sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
	sed -i "/^Protocol 2.*/a AllowUsers $YOURUSER" /etc/ssh/sshd_config
	
	# Creates basic UFW rule for SSH
	/usr/sbin/ufw allow ssh
	/usr/sbin/ufw enable
	/usr/sbin/ufw reload
	
	# Create fail2ban config
	cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
	sed -i 's/send = root@<fq-hostname>/send = root@localhost/g' /etc/fail2ban/jail.local
	sed -i "s/destemail = root@localhost/destemail = $YOURUSER@localhost/g" /etc/fail2ban/jail.local
	cat <<EOF | tee /etc/fail2ban/jail.d/sshd.conf
[sshd]
enabled = true
port = 22
mode = aggressive
EOF
		
	# adds your account to sudo users
	/usr/sbin/usermod -aG sudo $YOURUSER
	
	systemctl enable zerotier-one --now
	systemctl enable fail2ban.service --now
	systemctl restart sshd.service
	systemctl restart fail2ban.service
fi
exit 0