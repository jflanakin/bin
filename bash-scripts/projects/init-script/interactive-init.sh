#!/bin/bash
# This project was built to learn how to use libraries in bash.
# This project assumes Debian 11 and an Intel Based CPU or a hypervisor on an Intel based platform.
# This prepares a server for nearly any general purpose use.

# set -e

source ./library.sh

# Main function which runs the script.
main() {
	if [ "$EUID" -ne 0 ]
	then 
		echo "Please run as root"
		exit 1
	else
		USERNAME=""
		echo "This script will install necessary software as well as create a user with sudo privileges or give your existing user sudo privileges."
		read -s "What is your username? (If your user does not exist yet, what username would you like to use?)" USERNAME
		
		install_essential
		modify_user $USERNAME
		modify_ssh
		modify_fail2ban $USERNAME
		modify_ufw
		
		systemctl enable zerotier-one --now
		systemctl enable fail2ban.service --now
		systemctl restart sshd.service
		systemctl restart fail2ban.service
	fi
}

main
exit 0