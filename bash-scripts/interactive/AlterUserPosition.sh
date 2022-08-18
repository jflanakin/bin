#!/bin/bash
# Read username and password and store them as plaintext variables
read -p 'Please enter your Jamf Pro URL, including https:// : ' jssURL
read -p 'Please enter your Username: ' userName
read -sp 'Please enter your Password: ' userPass

# Simple iterative loop for my specific number of users. 
for i in {1..256}
do
	# This is the API call and data for this particular user modification, which updates the "Position" Attribute in Jamf Pro to be "Sales".
	curl --location --request PUT -u $userName:$userPass $jssURL/JSSResource/users/id/$i --header 'Accept: application/xml' --header 'Content-Type: application/xml' --data-raw '<user>
	<position>Sales</position>
</user>'
done
exit 0