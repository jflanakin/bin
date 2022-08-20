#!/bin/bash

# Interactive version of EncryptedStrings.
# Source: https://github.com/kc9wwh/EncryptedStrings
# Usage: /path/to/GenerateEncryptedString.sh

# Generate the encrypted string.
GenerateEncryptedString() {
	local plainTextPass=""
	read -sp "Enter your password here: " plainTextPass
	local STRING="${plainTextPass}"
	local SALT=$(openssl rand -hex 8)
	local K=$(openssl rand -hex 12)
	local ENCRYPTED=$(echo "${STRING}" | openssl enc -aes256 -a -A -S "${SALT}" -k "${K}")
	echo "Encrypted String: ${ENCRYPTED}"
	echo "Salt: ${SALT} | Passphrase: ${K}"
}

# Optionally checks to make sure that the decryption works correctly.
DecryptString() {
	local ENCRYPTED=""
	local SALT=""
	local K=""
	local verify=""
	read -p "Do you want to verify that the password can be decrypted correctly? [y/n]: " verify
	if [[ $verify = "y" ]] || [[ $verify = "Y" ]]
	then
		read -p "Enter the encrypted password: " ENCRYPTED
		read -p "Enter the salt: " SALT
		read -p "Enter the passphrase: " K
		echo "${ENCRYPTED}" | /usr/bin/openssl enc -aes256 -d -a -A -S "${SALT}" -k "${K}"
	else
		echo "Not Decrypting the password. Have a nice day!"
	fi
}

main(){
	GenerateEncryptedString
	DecryptString
}
# Call main function
main