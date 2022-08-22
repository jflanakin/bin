#!/bin/bash

global_token=""
jamfProURL=$(cat .jss-url)

__get_api_token(){
    # Set local variables
    local jamfProUser=$(cat .jss-user)
    local secret=$(cat .secret)
    local salt=$(cat .salt)
    local key=$(cat .key)
    local jamfProPass=$( echo "${secret}" | openssl enc -aes-256-cbc -md sha512 -a -A -d -S "${salt}" -k "${key}" )

    # Encode credentials and extract token from API call.
    local apiBasicPass=$( echo "$jamfProUser:$jamfProPass" | /usr/bin/iconv -t ISO-8859-1 | /usr/bin/base64 -i - )
    local getToken=$( curl -L -X POST $jamfProURL/api/v1/auth/token --header "Authorization: Basic $apiBasicPass" )
    local authToken=$(/usr/bin/plutil -extract token raw -o - - <<< "$getToken")
    global_token=$authToken
}

__invalidate_token(){
    local authToken=$1
    curl -L -X POST $jamfProURL/api/v1/auth/invalidate-token --header "Authorization: Bearer $authToken"
}

__trim(){
	value="$1"
	echo $value | sed 's:/*$::'
}

__save(){
	local name=$1
	local toSave=$2
	local path=$3
	# Can't use printf here because of character escaping. I guess I could if I was better at this, but this works just fine.
	echo "${name} is saved to ${path}"
	echo ""
	echo "${toSave}" > $path
	chmod 600 "${path}"
	chown $(whoami) "${path}"
}

# Generate the encrypted string.
_GenerateEncryptedString() {
	# Set local variables
	local path=""
	local default=$(pwd)
	local verify=""
	local plainTextString=""
	local secret=""
	local salt=$( /usr/bin/openssl rand -hex 8 )
	local key=$( /usr/bin/openssl rand -hex 32 )

	# Read the plain text string and encrypt it.
	echo ""
	read -sp "Please enter the string you'd like to encrypt: " plainTextString
	echo ""
	secret=$( echo "${plainTextString}" | /usr/bin/openssl enc -AES-256-CBC -md SHA512 -a -A -S "${salt}" -k "${key}" )

	# Clear plaintext string and print a new line.
	plainTextString=""
	echo ""

	# Show user the key, salt, and information.
	printf "Key: ${key}\n" 
	printf "Salt: ${salt}\n"
	printf "Secret: ${secret}\n"
	echo "Encrypted secret SHA256 sum: $(echo $secret | sha256sum)"
	echo ""

	# Ask to save information
	read -p "Would you like to save this information? [Y|N]: " verify
	echo ""
	if [[ $verify = "y" ]] || [[ $verify = "Y" ]]
	then
		read -p "Would you like to save to the default directory? (${default}) [Y|N]: " verify
		echo ""
		if [[ $verify = "y" ]] || [[ $verify = "Y" ]]
		then
			echo ""
			__save "Secret" "${secret}" "${default}/.secret"
			__save "Key" "${key}" "${default}/.key"
			__save "Salt" "${salt}" "${default}/.salt"
			printf "Make sure you do not lose or overwrite these files! If you do, the information will be lost forever.\n"
		else
			read -p "Please enter the directory you would like to save to: " path
			if [[ -d $path ]]
			then
				path=$( __trim $path )
				echo ""
				__save "Secret" "${secret}" "${path}/.secret"
				__save "Key" "${key}" "${path}/.key"
				__save "Salt" "${salt}" "${path}/.salt"
				printf "Make sure you do not lose or overwrite these files! If you do, the information will be lost forever.\n"
			else
				echo ""
				printf "Save path does not exist, cannot save. Exiting script.\n"
				exit 1
			fi
		fi
	else
		echo ""
		printf "Not saving this. Don't forget the information!\n"
	fi
}

# Optionally checks to make sure that the decryption works correctly.
_DecryptString() {
	# Set local variables
	local path=""
	local default=$( pwd )
	local verify=""
	local secret=""
	local key=""
	local salt=""
	local decrypted=""

	# Ask user if they'd like to decrypt the string
	echo ""
	read -p "Do you want to verify that the string can be decrypted correctly? [Y|N]: " verify
	if [[ $verify = "y" ]] || [[ $verify = "Y" ]]
	then
		echo ""
		read -p "Please enter the path where the files are saved. Default: ${default}): " path
		path=$(__trim $path)
		if [[ $path = $default ]] || [[ $path = "" ]]
		then
			echo ""
			secret=$( cat $default/.secret )
			key=$( cat $default/.key )
			salt=$( cat $default/.salt )
			decrypted=$( echo "${secret}" | openssl enc -aes-256-cbc -md sha512 -a -A -d -S "${salt}" -k "${key}" )
			echo "Encrypted secret SHA256 sum: $(echo $secret | sha256sum)"
			echo "Decrypted Secret: ${decrypted}"
		elif [[ -d $path ]] && [[ -f "$path/.secret" ]]
		then
			echo ""
			path=$(__trim $path)
			secret=$( cat $path/.secret )
			key=$( cat $path/.key )
			salt=$( cat $path/.salt )
			decrypted=$( echo "${secret}" | openssl enc -aes-256-cbc -md sha512 -a -A -d -S "${salt}" -k "${key}" )
			echo "Encrypted secret SHA256 sum: $(echo $secret | sha256sum)"
			echo "Decrypted Secret: ${decrypted}"
		else
			echo ""
			printf "Input path or input files do not exist, exiting script.\n"
			exit 1
		fi
	else
		echo ""
		printf "Not Decrypting the password. Have a nice day!\n"
	fi
}

main(){
	printf "This script generates an encrypted secret based on a string you provide. This is useful for encrypting passwords used in other scripts.\n"
	printf "Some special characters will break this script, such as \\ and single or double quotes. Please be sure to verify that the encrypted string can be decrypted correctly before using it anywhere.\n"
	_GenerateEncryptedString
	_DecryptString
    __get_api_token
}
# Call main function
main

