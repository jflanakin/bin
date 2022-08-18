#!/bin/bash

pkg install devcpu-data
pkg install gcc gmake check git gzip wget curl rsync nmon htop tmux neofetch bpytop

# vi /boot/loader.conf
# cat /boot/loader.conf
cpu_microcode_load="YES"
cpu_microcode_name="/boot/firmware/intel-ucode.bin"
# reboot

#!/bin/bash

Disable local packages:

sudo vi /usr/local/etc/pkg/repos/local.conf
# Change "enabled: yes" to "enabled: no" to turn off access to the local packages repo
Enable FreeBSD packages:

sudo vi /usr/local/etc/pkg/repos/FreeBSD.conf
# Change "enabled: no" to "enabled: yes" to allow access to the FreeBSD packages repo

pkg install drm-kmod gcc gmake check gzip wget curl rsync htop tmux neofetch zerotier zsh