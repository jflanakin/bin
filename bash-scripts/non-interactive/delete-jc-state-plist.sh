#!/bin/bash

# This script is meant to be run via policy in Jamf Pro.
# Running this script by itself though will likely work, unless you have a weird edge case.

# Get the logged in user
loggedInUser=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )

# Attempt to delete the state configuration profile.
if [[ -e "/Users/$loggedInUser/Library/Preferences/com.jamf.connect.state.plist" ]]; then
	echo "Deleting /Users/$loggedInUser/Library/Preferences/com.jamf.connect.state.plist"
	rm "/Users/$loggedInUser/Library/Preferences/com.jamf.connect.state.plist"
# Catch edge cases where the user folder is not named as the username and is instead named as the computer name. 
# (This is ridiculous I know, but I've seen it happen)
elif [[ -e "/Users/$2/Library/Preferences/com.jamf.connect.state.plist" ]]; then
	echo "/Users/$loggedInUser/Library/Preferences/com.jamf.connect.state.plist does not exist."
	echo "Deleting /Users/$2/Library/Preferences/com.jamf.connect.state.plist"
	rm "/Users/$2/Library/Preferences/com.jamf.connect.state.plist"
else
	echo "Neither /Users/$loggedInUser/Library/Preferences/com.jamf.connect.state.plist or /Users/$2/Library/Preferences/com.jamf.connect.state.plist were found"
	exit 1
fi
exit 0