#!/bin/bash
# Generates Apple Computer Model Types
generateComputerModelIdentifier(){
	local appleHardwareModels=(MacPro6,1 MacPro7,1 Macmini7,1 Macmini8,1 Macmini9,1 iMac16,1 iMac16,2 iMac17,1 iMac18,1 iMac18,2 iMac18,3 iMacPro1,1 iMac19,2 iMac19,1 iMac20,1 iMac20,2 iMac21,2 iMac21,1 MacBook9,1 MacBook10,1 MacBookAir7,1 MacBookAir7,2 MacBookAir7,2 MacBookAir8,1 MacBookAir8,2 MacBookAir9,1 MacBookAir10,1 MacBookPro12,1 MacBookPro11,4 MacBookPro11,5 MacBookPro13,1 MacBookPro13,2 MacBookPro13,3 MacBookPro14,1 MacBookPro14,2 MacBookPro14,3 MacBookPro15,2 MacBookPro15,1 MacBookPro15,2 MacBookPro15,1 MacBookPro15,3 MacBookPro15,4 MacBookPro16,1 MacBookPro16,4 MacBookPro16,2 MacBookPro16,3 MacBookPro17,1 MacBookPro18,1 MacBookPro18,2 MacBookPro18,3 MacBookPro18,4)

	local arrayLength=${#appleHardwareModels[@]}
	local arrayLength=$((arrayLength - 1))
	local randomNumber=$(echo $((RANDOM % $arrayLength + 0)))
	
	clientModelIdentifier=${appleHardwareModels[$randomNumber]}
}

generateComputerModelIdentifier
echo $clientModelIdentifier