#!/bin/bash

jamfProPass=$( echo "$6" | /usr/bin/openssl enc -aes256 -d -a -A -S "$8" -k "$9" )
apiBasicPass=$( printf "$jamfProUser:$jamfProPass" | /usr/bin/iconv -t ISO-8859-1 | /usr/bin/base64 -i - )
getToken=$( curl -L -X POST $jamfProURL/api/v1/auth/token --header "Authorization: Basic $apiBasicPass" )
authToken=$(/usr/bin/plutil -extract token raw -o - - <<< "$getToken")
