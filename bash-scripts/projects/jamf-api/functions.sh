#!/bin/bash

########=Globale Variables=########
global_token=""
jamfProURL=$(cat .jss-url)

########=Generate Authentication Details=########
_getApiToken(){
    # Set local variables
    local jamfProUser=$(cat .jss-user)
    local secret=$(cat .secret)
    local salt=$(cat .salt)
    local key=$(cat .key)
    local jamfProPass=$( echo "${secret}" | openssl enc -aes-256-cbc -md sha512 -a -A -d -S "${salt}" -k "${key}" )

    # Encode credentials and extract token from API call.
    local apiBasicPass=$( echo "$jamfProUser:$jamfProPass" | /usr/bin/iconv -t ISO-8859-1 | /usr/bin/base64 -i - )
    local getToken=$( curl -L -X POST $jamfProURL/api/v1/auth/token -H "Authorization: Basic $apiBasicPass" )
    local authToken=$(/usr/bin/plutil -extract token raw -o - - <<< "$getToken")
    global_token=$authToken
}

########=User Info Generation=########
_generateUserName(){
    userName=$(curl https://frightanic.com/goodies_content/docker-names.php)
}

_generateUserEmail(){
    userEmail=raccoon_called_$userName@fake.rubyraccoon.net
}

_generateUserPhone(){
    local fourNum=$(echo $((RANDOM % 9999 + 0)))
    local threeNum=$(echo $((RANDOM % 999 + 0)))
    phoneNumber=$"(${threeNum}) ${threenum}-${fourNum}"
}

_generateUsers(){
    _numberOfUsers
    local numUsers=""
    read -p "How many users would you like to create? (Max of 100 existing users + new users): " numUsers
    local totalUsers=$(($existingUsers + $numUsers))
    if [[ "$numUsers" -gt -1 ]] && [[ "$numUsers" -lt 100 ]] && [[ "$existingUsers" -lt 100 ]] && [[ "$totalUsers" -le 100 ]]
    then
        until [[ $numUsers -eq 0 ]]
        do
            _generateUserTemplate
            _createUser
            numUsers="$((numUsers - 1))"
        done
    else
        printf "Invalid number of users. Either there are too many users already in Jamf Pro or you are trying to create too many users at once. Please run this script again and enter a valid number of users."
    fi
}

########=Computer Info Generation=########
# Generates MAC address
_generateMAC(){
	clientMACValue1=$(openssl rand -hex 6)
	clientMACValue2=$(openssl rand -hex 6)
}

########=Mobile Device Info Generation=########
_generateBeans(){
    echo "beans"
}

########=Request Templates=########
_generateUserTemplate(){
    _generateUserName
    _generateUserEmail
    _generateUserPhone
    templateData="<user><name>${userName}</name><full_name>${userName}</full_name><email>${userEmail}</email><email_address>${userEmail}</email_address><phone_number>${phoneNumber}</phone_number><position>Raccoon</position></user>"
}

_generateComputerTemplate(){
    # stuff
    echo "rururu"
}

########=API Requests=########
_invalidateToken(){
    curl -L -X POST $jamfProURL/api/v1/auth/invalidate-token -H "Authorization: Bearer $global_token"
}

_createUser(){
    curl -L -k $jamfProURL/JSSResource/users/id/0 -H 'Accept: application/xml' -H 'Content-Type: application/xml' -H "Authorization: Bearer ${global_token}" -X POST -d "${templateData}"
}

_getUser(){
    Users=$(curl -L -k "${jamfProURL}/JSSResource/users" -H "accept: text/xml" -H "Authorization: Bearer ${global_token}" | xmllint --format -)
}

_numberOfUsers(){
    existingUsers=$(curl -L -k ${jamfProURL}/JSSResource/users -H "accept: text/xml" -H "Authorization: Bearer ${global_token}" | xmllint --xpath '//users/size/text()' -)
}

########=Main Function=########
<<Usage
    rururu
Usage
main(){
    _getApiToken
    _numberOfUsers
    echo $existingUsers
    _generateUsers
    _invalidateToken
}

main