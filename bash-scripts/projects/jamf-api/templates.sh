#!/bin/bash

jamfProURL=$(cat .jss-url)

########=User Info Generation=########
__generateUserName(){
    userName=$(curl https://frightanic.com/goodies_content/docker-names.php)
}

__generateUserEmail(){
    userEmail=raccoon_called_$userName@fake.rubyraccoon.net
}

__generateUserPhone(){
    local fourNum=$(echo $(($RANDOM % 9999 + 0)))
    local threeNum=$(echo $(($RANDOM % 999 + 0)))
    phoneNumber=$"(${threeNum}) ${threenum}-${fourNum}"
}

########=General Info Generation=########

__checkJSSVersion(){
    JSSversion=$(curl -sk "$jamfProURL/JSSCheckConnection" -w "\n")
}

__generateRandom(){
    randomNumber=$(echo $[ $RANDOM % $2 + $1 ])
}

# Generate a date for use in Jamf Pro
__generateDate(){
	local rangeInput="$1"

#|initial_entry_date_epoch|- enrollPercentage ->|last_enrolled_date_epoch| --- |report_date_epoch|<- reportPercentage -|last_contact_time_epoch|<- contactPercentage -| NOW
	local enrollPercentage=".1"
	local reportPercentage=".2"
	local contactPercentage=".01"

	#convert days to seconds
	local rangeSeconds="$((rangeInput * 86400))"
	#Get Epoch value
	local nowseconds=$(date +%s)
	#Calculate the lower bound of range epoch
	local clientRecordDate=$((nowseconds-rangeSeconds))
	#Convert to milliseconds for JSS submission
	local clientRecordDateValue="$((clientRecordDate * 1000))"

	local enrollRange=$(echo "scale=0;$clientRecordDate+(($rangeInput*$enrollPercentage)*86400) / 1" |bc) 
	# need to make this
    __generateRandom $clientRecordDate $enrollRange
	local clientEnrollDate=$randomNumber

	local reportRange=$(echo "scale=0;$nowseconds-(($rangeInput*$reportPercentage)*86400) / 1" |bc)
	__generateRandom $reportRange $nowseconds
	local clientReportDate=$randomNumber

	local contactRange=$(echo "scale=0;$nowseconds-(($rangeInput*$contactPercentage)*86400) / 1" |bc)
	__generateRandom $contactRange $nowseconds
	local clientCheckinDate=$randomNumber

	#Convert to milliseconds for JSS submission
	clientRecordDateValue="$((clientRecordDate * 1000))"
	clientEnrollDateValue="$((clientEnrollDate * 1000))"
	clientReportDateValue="$((clientReportDate * 1000))"
	clientCheckinDateValue="$((clientCheckinDate * 1000))"

}

# Generate IP Address
__generateIP(){
    for i in {1..5}
    do
        __generateRandom 20 250
        export r"$i"="$randomNumber"
    done

    externalIPValue="$r1.$r2.$r3.$r4"
    internalIPValue="10.0.0.$r5"
}

# Generates MAC address
__generateMAC(){
	MACPart1=$(openssl rand -hex 6)
	MACPart2=$(openssl rand -hex 6)
}

# Generates Serial Number
__generateSerial(){
	serialNumber=$(openssl rand -hex 6 | awk '{print toupper($0)}' )
}

# Generates UUID
__generateUUID(){
	UUID=$(uuidgen)
}

########=Computer Info Generation=########
__generateComputerName(){
    __generateRandom 999 9999
    computerName="device_$randomNumber"
}

# Generates Apple Computer Model Types
__generateComputerModelIdentifier(){
	local appleHardwareModels=(MacPro6,1 MacPro7,1 Macmini7,1 Macmini8,1 Macmini9,1 iMac16,1 iMac16,2 iMac17,1 iMac18,1 iMac18,2 iMac18,3 iMacPro1,1 iMac19,2 iMac19,1 iMac20,1 iMac20,2 iMac21,2 iMac21,1 MacBook9,1 MacBook10,1 MacBookAir7,1 MacBookAir7,2 MacBookAir7,2 MacBookAir8,1 MacBookAir8,2 MacBookAir9,1 MacBookAir10,1 MacBookPro12,1 MacBookPro11,4 MacBookPro11,5 MacBookPro13,1 MacBookPro13,2 MacBookPro13,3 MacBookPro14,1 MacBookPro14,2 MacBookPro14,3 MacBookPro15,2 MacBookPro15,1 MacBookPro15,2 MacBookPro15,1 MacBookPro15,3 MacBookPro15,4 MacBookPro16,1 MacBookPro16,4 MacBookPro16,2 MacBookPro16,3 MacBookPro17,1 MacBookPro18,1 MacBookPro18,2 MacBookPro18,3 MacBookPro18,4)

	local arrayLength=${#appleHardwareModels[@]}
	local arrayLength=$((arrayLength - 1))
    __generateRandom 0 $arrayLength
	
	clientModelIdentifier=${appleHardwareModels[$randomNumber]}
}

########=Mobile Device Info Generation=########
__generateBeans(){
    echo "beans"
}


########=Request Templates=########
_generateUserTemplate(){
    __generateUserName
    __generateUserEmail
    __generateUserPhone
    userTemplateData="<user><name>${userName}</name><full_name>${userName}</full_name><email>${userEmail}</email><email_address>${userEmail}</email_address><phone_number>${phoneNumber}</phone_number><position>Raccoon</position></user>"
}

_generateComputerTemplate(){
    
    __generateComputerName
    __generateMAC
    __generateIP
    __generateSerial
    __generateUUID
    __checkJSSVersion
    __generateDate

    computerTemplateData="<computer><general><name>${computerName}</name><mac_address>${MACPart1}</mac_address><alt_mac_address>${MACPart2}</alt_mac_address><ip_address>${internalIPValue}</ip_address><last_reported_ip>${externalIPValue}</last_reported_ip><serial_number>${serialNumber}</serial_number><udid>${UUID}</udid><jamf_version>${JSSversion}</jamf_version><platform>Mac</platform><remote_management><managed>true</managed><management_username>computer1</management_username><management_password>jamf1234</management_password></remote_management><mdm_capable>true</mdm_capable><mdm_capable_users/><report_date_epoch>${clientReportDateValue}</report_date_epoch><last_contact_time_epoch>${clientCheckinDateValue}</last_contact_time_epoch><initial_entry_date_epoch>${clientRecordDateValue}</initial_entry_date_epoch><last_cloud_backup_date_epoch>${clientBackupDateValue}</last_cloud_backup_date_epoch><last_enrolled_date_epoch>${clientEnrollDateValue}</last_enrolled_date_epoch></general><hardware><make>Apple</make><model_identifier>${clientModelIdentifier}</model_identifier><os_name>macOS</os_name><os_version>12.5.0</os_version></hardware></computer>"
}