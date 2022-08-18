#!/bin/bash

# Verify user is NOT running as root or with sudo
if [ "$EUID" -ne 0 ]
then 
	# reset k8 cluster
	sudo kubeadm reset -f
	
	# remove k8 files and folders
	sudo rm -rf /etc/cni /etc/kubernetes /var/lib/dockershim /var/lib/etcd /var/lib/kubelet /var/run/kubernetes ~/.kube/*
	
	# Configurations
	IPTABLES="/sbin/iptables"
	
	# reset the default policies in the filter table.
	sudo $IPTABLES -P INPUT ACCEPT
	sudo $IPTABLES -P FORWARD ACCEPT
	sudo $IPTABLES -P OUTPUT ACCEPT
	
	# reset the default policies in the nat table.
	sudo $IPTABLES -t nat -P PREROUTING ACCEPT
	sudo $IPTABLES -t nat -P POSTROUTING ACCEPT
	sudo $IPTABLES -t nat -P OUTPUT ACCEPT
	
	# reset the default policies in the mangle table.
	sudo $IPTABLES -t mangle -P PREROUTING ACCEPT
	sudo $IPTABLES -t mangle -P POSTROUTING ACCEPT
	sudo $IPTABLES -t mangle -P INPUT ACCEPT
	sudo $IPTABLES -t mangle -P OUTPUT ACCEPT
	sudo $IPTABLES -t mangle -P FORWARD ACCEPT
	
	# flush all the rules in the filter and nat tables.
	sudo $IPTABLES -F
	sudo $IPTABLES -t nat -F
	sudo $IPTABLES -t mangle -F
	
	# erase all chains that's not default in filter and nat table.
	sudo $IPTABLES -X
	sudo $IPTABLES -t nat -X
	sudo $IPTABLES -t mangle -X
	
	# restart container runtime
	sudo systemctl restart crio
else
	echo "Do not run this script as root or with sudo."
	exit 1
fi
exit 0