#!/bin/bash
 	uname1=`defaults read /Library/Preferences/com.apple.loginwindow lastUserName`
 	uname2=`stat -f "%Su" /dev/console`
 	uname3=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
 	log_file=/var/tmp/jc_login.log
 	touch $log_file
 	sudo -u $uname1 open https://www.google.com
 	echo "uname1 $uname1" >> $log_file
 	sudo -u $uname2 open https://www.ibm.com
 	echo "uname2 $uname2" >> $log_file
 	sudo -u $uname3 open https://www.apple.com
 	echo "uname3 $uname3" >> $log_file
 	 
 	exit 0
