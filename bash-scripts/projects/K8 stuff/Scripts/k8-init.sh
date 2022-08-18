#!/bin/bash
# Verify user is NOT running as root or with sudo
if [ "$EUID" -ne 0 ]
then 
	# Change the IP addresses to what you need them to be.
	sudo kubeadm init --apiserver-advertise-address=10.10.10.15 --pod-network-cidr=10.20.20.0/16
	sleep 1
	mkdir -p $HOME/.kube
	sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
	sudo chown $(id -u):$(id -g) $HOME/.kube/config
else	
	echo "Do not run this script as root or with sudo."
	exit 1
fi
	exit 0