#!/bin/sh
#
# DOCKER compatible backup script. Works with single node docker swarm or docker compose
#
  
timestamp=$(date +%Y%m%d_%H_%M_%S)
prefix=$1
retainqty=3
  
# Location to place the backup files
backup_dir="/opt/hubbackupdumps/"
 
# Log file location.
logfile="/opt/hubbackupdumps/hub_pgdump.log"
 
 
if [ "$1" = "" ]
then
        prefix=daily
fi
  
#Finding the container id
container_id=$(docker container ls | grep -E '(hub-postgres|blackduck-postgres)' | awk '{print $1}')
  
if [ $container_id != "" ]
then
        echo "Backup started at $(date +%Y%m%d_%H_%M_%S)  for bds_hub database" >> $logfile
        /bin/docker exec -i $container_id  pg_dump -U blackduck -Fc -f /tmp/bds_hub.dump bds_hub
        if [ $? == 0 ]
        then
                /bin/docker cp $container_id:/tmp/bds_hub.dump $backup_dir/${prefix}_bds_hub_$timestamp.dump
                echo -e "Backup completed at $(date +%Y%m%d_%H_%M_%S) for bds_hub database \n" >> $logfile
        else
                echo -e "Backup  failed at $(date +%Y%m%d_%H_%M_%S) \n" >> $logfile
                exit 1
        fi
else
        echo -e "Container id not found at $(date +%Y%m%d_%H_%M_%S) \n" >> $logfile
        exit 1
fi
  
#find "$backup_dir/" -mtime +20 -name bds_hub_*.dump -exec rm {} \;
  
# Leaving only the last $retainqty backup files for backup $prefix
  
dumpcount=$(ls $backup_dir/${prefix}* | wc -l)
if [ $dumpcount -gt $retainqty ]
then
        rm $(ls -r $backup_dir/${prefix}* | tail -n $(( $dumpcount - $retainqty )) )
fi
