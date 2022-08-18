#!/bin/bash
test=$(/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -title 'Jamf Helper Test' -description 'Testing the buttons' -defaultButton 1 -cancelButton2 -button1 'test1' -button2 'test2')
if  [ $test -eq 0 ]; then
	echo "you pressed button 1"
else
	echo "you pressed button 2"
fi
