#!/bin/bash
now=$(date +"%F_%H-%M")
mysqldump --all-databases --single-transaction --quick --lock-tables=false --user=root --password=rootCatratbat2@ > /home/shichi/backups/mysql/database.sql
rsync -rav /etc/mysql/ /home/shichi/backups/mysql/
tar -czvf /home/shichi/backups/backup_$now.tar.gz /home/shichi/backups/mysql/
rsync -a /home/shichi/backups/backup_$now.tar.gz /mnt/truenas/ 
rm -rf /home/shichi/backups/mysql/* /home/shichi/backups/backup_$now.tar.gz
exit 0 ##success
exit 1 ##failure