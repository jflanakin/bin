import requests
import base64

message_bytes = message.encode('ascii')
base64_bytes = base64.b64encode(message_bytes)
base64_message = base64_bytes.decode('ascii')

print(base64_message)


username="jss-api@rubyraccoon.net"
password="#yKZx*KEu9wDPkg742WJ%r77Y9k&$ee2ZM#HqtT6e2Uxx8$^T23JAP@z#*AQ"
message = ""

response = requests.post("https://julyflanakin.jamfcloud.com/api/v1/auth/token", "Accept": "application/json" )

print(response.text)