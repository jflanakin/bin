#!/bin/bash
# This script is written for Debian 11 created with no swap space
# If using swap, uncomment the swap lines

# Replace $YOURUSER with your username. 
# Setting that value as a variable has had... mixed results, so just suffer
#   editing this script once you download it to change the name.
# Use are your own risk

# Verify user is running as root or with sudo
if [ "$EUID" -ne 0 ]
then echo "Please run as root"
	exit
else	
	# Add non-free and contrib repositories
	cp /etc/apt/sources.list /etc/apt/sources.list.bak
	sed -i 's/bullseye main/bullseye main contrib non-free/' /etc/apt/sources.list
	
	# Install any updates
	apt -y update
	
	# Uncomment if your OS uses swap space
	# sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
	# swapoff -a
	
	# enable overlay and netfilter
	cat <<EOF | sudo tee /etc/modules-load.d/crio.conf
overlay
br_netfilter
EOF
	modprobe overlay
	modprobe br_netfilter
	
	# Configure network settings for k8
	tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
	sleep 2

	# Reload sysctl
	sysctl --system
	
	# Install required and preferred software
	apt -y install intel-microcode build-essential dkms linux-headers-$(uname -r)
	apt -y install sudo vim open-vm-tools molly-guard fail2ban dnsutils net-tools gnupg2 apt-transport-https software-properties-common ca-certificates 
	# These are mostly optional but very recommended
	apt -y install gcc make check git tar gzip wget curl rsync nmon htop tmux neofetch zsh bpytop
	
	# install cri-o
	echo "deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_11/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
	echo "deb [signed-by=/usr/share/keyrings/libcontainers-crio-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/1.24:/1.24.1/Debian_11/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:1.24:1.24.1.list
	mkdir -p /usr/share/keyrings
	curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_11/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-archive-keyring.gpg
	curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/1.24:/1.24.1/Debian_11/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-crio-archive-keyring.gpg
	apt update
	apt install -y cri-o cri-o-runc
	
	# install zerotier
	curl -s 'https://raw.githubusercontent.com/zerotier/ZeroTierOne/master/doc/contact%40zerotier.com.gpg' | gpg --import && \
	if z=$(curl -s 'https://install.zerotier.com/' | gpg); then echo "$z" | sudo bash; fi
	
	# install k8
	curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
	echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
	sudo apt update
	sudo apt install -y kubelet kubeadm kubectl
	
	# Modify SSH config
	cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
	sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
	sed -i '/^#MaxSessions 10.*/a Protocol 2' /etc/ssh/sshd_config
	sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
	sed -i '/^Protocol 2.*/a AllowUsers $YOURUSER' /etc/ssh/sshd_config
	
	# Create fail2ban config
	cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
	sed -i 's/send = root@<fq-hostname>/send = root@localhost/g' /etc/fail2ban/jail.local
	sed -i 's/destemail = root@localhost/destemail = $YOURUSER@localhost/g' /etc/fail2ban/jail.local
	cat <<EOF | tee /etc/fail2ban/jail.d/sshd.conf
[sshd]
enabled = true
port = 22
mode = aggressive
EOF
		
	# export path because apparently you have to still do this sometimes
	export PATH=/usr/sbin/:$PATH/
	
	# adds your account to sudo users
	usermod -aG sudo $YOURUSER
	
	# enable and restart services
	systemctl daemon-reload
	systemctl enable zerotier-one --now
	systemctl enable crio --now
	systemctl enable kubelet --now
	systemctl enable fail2ban.service --now
	systemctl restart sshd.service
	systemctl restart fail2ban.service
	systemctl restart crio
	systemctl restart kubelet
	
	# Set up K8 audit log
	mkdir -p /etc/kubernetes
	cat > /etc/kubernetes/audit-policy.yaml <<EOF
	apiVersion: audit.k8s.io/v1beta1
	kind: Policy
	rules:
	- level: Metadata
EOF
	mkdir -p /var/log/kubernetes/audit
	
	# Create NetworkManager config to ignore Flannel CNI
	cat > /etc/NetworkManager/conf.d/cni.conf <<EOF
[keyfile]
unmanaged-devices=interface-name:flannel.1;interface-name:veth*;interface-name:cni0
EOF
fi
exit 0 ##success
exit 1 ##failure