#!/bin/bash

__get_api_token(){
    # Set local variables
    local __authtoken="$1"
    local jamfProURL="https://julyflanakin.jamfcloud.com"
    local jamfProUser="jss-api@rubyraccoon.net"
    # local jamfProPass='#yKZx*KEu9wDPkg742WJ%r77Y9k&$ee2ZM#HqtT6e2Uxx8$^T23JAP@z#*AQ'
    local jamfProPass="$(echo "${ENCRYPTED}" | /usr/bin/openssl enc -aes256 -d -a -A -S "${SALT}" -k "${K}")"
    #read -p "Enter your Jamf Pro URL, including https:// : " jamfProURL
    #read -p "Enter your Jamf Pro API account username: " jamfProUser
    #read -sp "Enter your Jamf Pro API account password: " jamfProPass

    # Encode credentials and extract token from API call.
    local apiBasicPass=$( echo "$jamfProUser:$jamfProPass" | /usr/bin/iconv -t ISO-8859-1 | /usr/bin/base64 -i - )
    local getToken=$( curl -L -X POST $jamfProURL/api/v1/auth/token --header "Authorization: Basic $apiBasicPass" )
    local authToken=$(/usr/bin/plutil -extract token raw -o - - <<< "$getToken")
    eval $__authtoken="'$authToken'"
}

__invalidate_token(){
    curl -L -X POST $jamfProURL/api/v1/auth/invalidate-token --header "Authorization: Basic $apiBasicPass"
}

__evaluate_user(){
    local authtoken="$1"

}