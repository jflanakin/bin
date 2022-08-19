#!/bin/bash
# replace $YOURUSER with your username or change the script path
# vim /home/$YOURUSER /bin/mount-cifs.sh
# chmod 755 /home/$YOURUSER /bin/mount-cifs.sh

# literally all this does is ensure that the VPN connection is made before
# attempting to mount an SMB share over the VPN
sleep 60
mount -a