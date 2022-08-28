#!/bin/bash

jamfProURL="https://julyflanakin.jamfcloud.com"

_getApiToken(){
    # Set local variables
    local jamfProUser=$(cat .jss-user)
    local secret=$(cat .secret)
    local salt=$(cat .salt)
    local key=$(cat .key)
    local jamfProPass=$( echo "${secret}" | openssl enc -aes-256-cbc -md sha512 -a -A -d -S "${salt}" -k "${key}" )

    # Encode credentials and extract token from API call.
    local apiBasicPass=$( echo "$jamfProUser:$jamfProPass" | /usr/bin/iconv -t ISO-8859-1 | /usr/bin/base64 -i - )
    local getToken=$( curl -s -k -L -X POST $jamfProURL/api/v1/auth/token -H "Authorization: Basic $apiBasicPass" )
    local authToken=$(/usr/bin/plutil -extract token raw -o - - <<< "$getToken")
    global_token=$authToken
}

_getApiToken

numberOfComputers=$(curl -X GET "${jamfProURL}/JSSResource/computers" -H 'Content-Type: application/xml' -H "Authorization: Bearer ${global_token}" | xmllint --xpath '//computers/size/text()' -)
computerID=$(curl -X GET "${jamfProURL}/JSSResource/computers" -H 'Content-Type: application/xml' -H "Authorization: Bearer ${global_token}" | xmllint --xpath '//computers/computer/id/text()' -)

until [[ $numberOfComputers -eq 0 ]]
do
    curl -X GET "${jamfProURL}/JSSResource/computers/id/{$computerID}/subset/groups_accounts" -H 'Content-Type: application/xml' -H "Authorization: Bearer ${global_token}" | xmllint --format -
    numberOfComputers=$((numberOfComputers -1))
done

xmllint --xpath "concat((//identity)[$i]/name,', ',(//identity)[$i]/placeofbirth, ', ', (//identity)[$i]/photo)" - ; echo