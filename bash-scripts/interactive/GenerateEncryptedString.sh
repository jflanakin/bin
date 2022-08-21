#!/bin/bash

# Interactive version of EncryptedStrings.
# Source: https://github.com/kc9wwh/EncryptedStrings
# Usage: bash GenerateEncryptedString.sh

# Generate the encrypted string.
GenerateEncryptedString() {
	# Set local variables
	local path=""
	local verify=""
	local plainTextString=""
	local secret=""
	local salt=$( /usr/bin/openssl rand -hex 8 )
	local key=$( /usr/bin/openssl rand -hex 32 )

	# Read the plain text string and encrypt it.
	read -sp "Please enter the string you'd like to encrypt: " plainTextString
	secret=$( echo "${plainTextString}" | /usr/bin/openssl enc -AES-256-CBC -md SHA512 -a -A -S "${salt}" -k "${key}" )

	# Clear plaintext string
	plainTextString=""

	echo "Key: ${key} | Salt: ${salt}"
	echo "Secret: ${secret}"

	read -p "Do you want to save the encrypted string and key? [Y|N]: " verify
	if [[ $verify = "y" ]] || [[ $verify = "Y" ]]
	then
		read -p "Please enter the directory you would like to save the encrypted string and key to: " path
		echo "Encrypted string: ${path}/.secret."
		echo "Key: ${path}/.key"
		echo "Salt: ${path}/.salt" 
		echo $secret > $path/.secret
		echo $key > $path/.key
		echo $salt > $path/.salt
		echo "Make sure you do not lose or overwrite these files! If you do, the information will be lost forever."
	else
		echo "Not saving the keypair."
	fi
}

# Optionally checks to make sure that the decryption works correctly.
DecryptString() {
	local path=""
	local verify=""
	read -p "Do you want to verify that the password can be decrypted correctly? [y/n]: " verify
	if [[ $verify = "y" ]] || [[ $verify = "Y" ]]
	then
		read "Please enter the full path to the encrypted secret and key: "
		local secret=$( cat $path/.secret )
		local key=$( cat $path/.key )
		local salt=$( cat $path/.salt )
		local decrypted=$( echo "${secret}" | openssl enc -aes-256-cbc -md sha512 -a -A -d -S "${salt}" -k "${key}" )
		echo "Decrypted Secret: ${decrypted}"
	else
		echo "Not Decrypting the password. Have a nice day!"
	fi
}

main(){
	echo "This script generates an encrypted secret based on a string you provide. This is useful for encrypting passwords used in other scripts."
	GenerateEncryptedString
	DecryptString
}
# Call main function
main