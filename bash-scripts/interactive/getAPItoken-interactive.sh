#!/bin/bash
# This is a basic example of how to use the Jamf Pro API in an interactive script
#   in order to acquire a bearer token for later user.
read -p "Enter your Jamf Pro URL, including https:// : " jamfProURL
read -p "Enter your Jamf Pro API account username: " jamfProUser
read -sp "Enter your Jamf Pro API account password: " jamfProPass

apiBasicPass=$( echo "$jamfProUser:$jamfProPass" | /usr/bin/iconv -t ISO-8859-1 | /usr/bin/base64 -i - )
getToken=$( curl -L -X POST $jamfProURL/api/v1/auth/token --header "Authorization: Basic $apiBasicPass" )
authToken=$(/usr/bin/plutil -extract token raw -o - - <<< "$getToken")

echo $authToken

# Example usage of this token with classic/universal API: 
curl -L $jamfProURL/JSSResource/computers --header 'Accept: application/xml' --header "Authorization: Basic ${apiBasicPass}" | xmllint --format -

# Example usage of this token with classic/universal API and xpath: 
curl -L $jamfProURL/JSSResource/computers --header 'Accept: application/xml' --header "Authorization: Basic ${apiBasicPass}" | xmllint --format --xpath '//computer/name/text()' -