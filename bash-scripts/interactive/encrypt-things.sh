#!/bin/bash

# stuff and things :)
# https://stackoverflow.com/questions/1602378/how-to-calculate-a-hash-for-a-string-url-in-bash-for-wget-caching
# https://www.unix.com/shell-programming-and-scripting/203277-read-user-input-encrypt-data-write-file.html


encrypt_String() {
	local string=$1
	local salt=$(openssl rand -hex 8)
	local K=$(openssl rand -hex 12)
	local encryptedPassword=$(echo "${string}" | openssl enc -aes256 -a -A -S "${salt}" -k "${K}")
	passwordHash=$(echo "${encryptedPassword}" | /usr/bin/md5sum | /bin/cut -f1 -d" ")
}

function create_Password() {
	local plainTextPassword=""
	local plainTextConfirm=""
	# Set a password for the new user: 
	read -sp "Please enter a password for $user: " plainTextPassword
	# confirm password: 
	read -sp "Please confirm the password for $user:" plainTextConfirm
}