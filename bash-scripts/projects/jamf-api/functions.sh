#!/bin/bash

global_token=""

__get_api_token(){
    # Set local variables
    local jamfProURL=$(cat .jss-url)
    local jamfProUser=$(cat .jss-user)
    local secret=$(cat .secret)
    local salt=$(cat .salt)
    local key=$(cat .key)
    local jamfProPass=$( echo "${secret}" | openssl enc -aes-256-cbc -md sha512 -a -A -d -S "${salt}" -k "${key}" )

    # Encode credentials and extract token from API call.
    local apiBasicPass=$( echo "$jamfProUser:$jamfProPass" | /usr/bin/iconv -t ISO-8859-1 | /usr/bin/base64 -i - )
    local getToken=$( curl -s -L -X POST $jamfProURL/api/v1/auth/token --header "Authorization: Basic $apiBasicPass" )
    local authToken=$(/usr/bin/plutil -extract token raw -o - - <<< "$getToken")
    global_token=$authToken
}

__invalidate_token(){
    local authToken=$1
    local jamfProURL=$(cat .jss-url)
    curl -L -X POST $jamfProURL/api/v1/auth/invalidate-token --header "Authorization: Bearer $authToken"
}

__get_api_token

echo $global_token

__invalidate_token $global_token
__invalidate_token $global_token