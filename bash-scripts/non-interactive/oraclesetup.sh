#!/bin/bash
# ***WARNING DANGER - this changes the SSH port from 22 to 6621***

# Replace $YOURUSER with your username. 
# Setting that value as a variable has had... mixed results, so just suffer
#   editing this script once you download it to change the name.

# Verify user is running as root or with sudo
if [ "$EUID" -ne 0 ]
then echo "Please run as root"
	exit
else	
	# enable EPEL
	sed -i 's/enabled=0/enabled=1/g' /etc/yum.repos.d/oracle-epel-ol8.repo
	
	# update and install software
	dnf update -y
	dnf install -y dkms fail2ban gcc make check git tar gzip wget curl rsync nmon htop tmux neofetch zsh bpytop policycoreutils-python-utils
	
	# install zerotier
	curl -s 'https://raw.githubusercontent.com/zerotier/ZeroTierOne/master/doc/contact%40zerotier.com.gpg' | gpg --import && \
	if z=$(curl -s 'https://install.zerotier.com/' | gpg); then echo "$z" | sudo bash; fi
	
	# create user and add ssh key
	useradd $YOURUSER
	usermod -aG wheel $YOURUSER
	cp -r /home/opc/.ssh /home/$YOURUSER/.ssh
	chown -R $YOURUSER:$YOURUSER /home/$YOURUSER/.ssh
	
	# create firewall and selinux rules for later
	semanage port -a -t ssh_port_t -p tcp 6621
	firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="10.10.0.0/16" port protocol="tcp" port="6621" accept'
	firewall-cmd --reload
	
	# Modify SSH config
	# WARNING - this changes the SSH port from 22 to 6621
	cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
	sed -i 's/#Port 22/Port 6621/g' /etc/ssh/sshd_config
	sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
	sed -i '/^#MaxSessions 10.*/a Protocol 2' /etc/ssh/sshd_config
	sed -i '/^Protocol 2.*/a AllowUsers $YOURUSER' /etc/ssh/sshd_config
	
	# Create fail2ban config
	cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
	sed -i 's/send = root@<fq-hostname>/send = root@localhost/g' /etc/fail2ban/jail.local
	sed -i 's/destemail = root@localhost/destemail = $YOURUSER@localhost/g' /etc/fail2ban/jail.local
	cat <<EOF | tee /etc/fail2ban/jail.d/sshd.conf
[sshd]
enabled = true
port = 6621
mode = aggressive
EOF
	systemctl enable zerotier-one --now
	systemctl enable fail2ban --now
	systemctl restart fail2ban
	systemctl restart sshd
fi
exit 0 ##success
exit 1 ##failure