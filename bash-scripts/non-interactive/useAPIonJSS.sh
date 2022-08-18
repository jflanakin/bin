#!/bin/bash

<<usage
This is a script meant to be deployed with Jamf Pro to run API calls on
  computers remotely. This is just the first part of the script to acquire a
  bearer token to user API calls further in the script.

Usage:
1. Generate an encrypted password with the GenerateEncryptedString.sh script
2. Create a script in Jamf Pro, then copy/paste this script and add any API calls 
  you desire.
3. Click the "Options" tab and set these names for the options:
Parameter 4: Jamf Pro URL (https://yourinstance.jamfcloud.com or https://jamf.yourdomain.com)
Parameter 5: Jamf Pro User
Parameter 6: Jamf Pro Password (encrypted)
Parameter 7: Salt
Parameter 8: Passphrase
3. When deploying via policy, enter the correct values for the script
	options, including the encrypted password, salt, and passphrase. 
usage

jamfProURL="$4"
jamfProUser="$5"
jamfProPassEnc="$6"
jamfProPass=$( echo "$6" | /usr/bin/openssl enc -aes256 -d -a -A -S "$7" -k "$8" )
apiBasicPass=$( printf "$jamfProUser:$jamfProPass" | /usr/bin/iconv -t ISO-8859-1 | /usr/bin/base64 -i - )
getToken=$( curl -k -L -X POST $jamfProURL/api/v1/auth/token --header "Authorization: Basic $apiBasicPass" )
authToken=$(/usr/bin/plutil -extract token raw -o - - <<< "$getToken")

# Example usage of this token with classic/universal API: 
curl -L $jamfProURL/JSSResource/computers --header 'Accept: application/xml' --header "Authorization: Bearer ${authToken}" | xmllint --format -