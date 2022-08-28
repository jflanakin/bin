#!/bin/bash

source templates.sh

########=Globale Variables=########
global_token=""
jamfProURL=$(cat .jss-url)

########=Authentication Flow=########
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

_invalidateToken(){
    curl -s -k -L -X POST $jamfProURL/api/v1/auth/invalidate-token -H "Authorization: Bearer $global_token"
}

########=Generate Objects=########
_generateUsers(){
    _numberOfUsers
    local numUsers=""
    read -p "How many users would you like to create? (Max of 100 existing users + new users): " numUsers
    local totalUsers=$(($existingUsers + $numUsers))
    if [[ "$numUsers" -gt 0 ]] && [[ "$numUsers" -lt 100 ]] && [[ "$existingUsers" -lt 100 ]] && [[ "$totalUsers" -le 100 ]]
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

_generateComputers(){
    local numComputers=""
    read -p "How many computer objects would you like to create? (Max of 100 existing users + new users): " numComputers
    if [[ "$numComputers" -gt 0 ]] && [[ "$numComputers" -lt 100 ]]
    then
        until [[ $numComputers -eq 0 ]]
        do
            _generateComputerTemplate
            _createComputer
            numComputers="$((numComputers - 1))"
        done
    else
        printf "Invalid number of computers. Either there are too many computers already in Jamf Pro or you are trying to create too many computers at once. Please run this script again and enter a valid number of computers."
    fi
}

########=Classic API Functions=########
_createUser(){
    curl -L -k $jamfProURL/JSSResource/users/id/0 -H 'Accept: application/xml' -H 'Content-Type: application/xml' -H "Authorization: Bearer ${global_token}" -X POST -d "${userTemplateData}"
}

_createComputer(){
    curl -s -k -L -X $jamfProURL/JSSResource/computers/id/0 -H 'Accept: application/xml' -H 'Content-Type: application/xml' -H "Authorization: Bearer ${global_token}" -X POST -d "${computerTemplateData}"
}

_getUser(){
    Users=$(curl -s -k -L -X "${jamfProURL}/JSSResource/users" -H "accept: text/xml" -H "Authorization: Bearer ${global_token}" | xmllint --format -)
}

_numberOfUsers(){
    existingUsers=$(curl -s -k -L -X ${jamfProURL}/JSSResource/users -H "accept: text/xml" -H "Authorization: Bearer ${global_token}" | xmllint --xpath '//users/size/text()' -)
}

########=Jamf API Functions=########

_numberOfComputers(){
    numComputers=$(curl -s -k -L -X GET "${jamfProURL}/api/v1/computers-inventory?section=GENERAL&page=0&page-size=10&sort=id%3Aasc" -H "accept: application/json" -H "Authorization: Bearer ${global_token}" | jq '.totalCount' )
}

_getComputerInventoryReport(){
    _numberOfComputers
    local totalComputers="$numComputers"
    echo "The total number of computers is ${totalComputers}"
    totalComputers="$((numComputers - 1))"
    until [[ "$totalComputers" -eq -1 ]]
    do
        computerID="$(curl -s -k -L -X GET "${jamfProURL}/api/v1/computers-inventory?section=GENERAL&page=0&page-size=10&sort=id%3Aasc" -H "accept: application/json" -H "Authorization: Bearer ${global_token}" | jq ".results[${totalComputers}].id" )"

        echo "The computer ID is ${computerID}"

        computerInventoryReport=$(curl -s -k -L -X GET "${jamfProURL}/api/v1/computers-inventory-detail/${computerID}" -H "accept: application/json" -H "Authorization: Bearer ${global_token}" | jq '.general' )

        echo "$computerInventoryReport"

        totalComputers="$((totalComputers - 1))"
    done
}



########=Main Function=########
<<Usage
    rururu
Usage
main(){
    _getApiToken
#    _generateComputers
#    _numberOfUsers
#    echo $existingUsers
#    _generateUsers
    _getComputerInventoryReport
    #echo $computerInventoryReport


    _invalidateToken
}

main