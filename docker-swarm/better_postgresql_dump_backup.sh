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

# Databases to back up
dblist="bds_hub bdio bds_hub_report"


if [ "$1" = "" ]
then
        prefix=daily
fi

#Finding the container id
container_id=$(docker container ls | grep -E '(hub-postgres|blackduck-postgres)' | awk '{print $1}')

if [ $container_id != "" ]
then
    for i in $dblist
    do
        dumpfile=${backup_dir}/${prefix}_${i}_${timestamp}.dump
        echo "Backup started at $(date +%Y%m%d_%H_%M_%S)  for ${i} database" >> $logfile
        /bin/docker exec -i $container_id  pg_dump -U blackduck -Fc -f ${i}  >${dumpfile}
        if [ $? == 0 ]
        then
            echo -e "Backup completed at $(date +%Y%m%d_%H_%M_%S) for bds_hub database \n" >> $logfile
        else
            echo -e "Backup  failed at $(date +%Y%m%d_%H_%M_%S) \n" >> $logfile
            exit 1
        fi
        dumpfilepattern=${backup_dir}/${prefix}_${i}_[0-9]
        dumpcount=$(ls ${dumpfilepattern}* | wc -l)
        if [ $dumpcount -gt $retainqty ]
        then
          rm $(ls -r ${dumpfilepattern}* | tail -n $(( $dumpcount - $retainqty )) )
        fi
    done
else
        echo -e "Container id not found at $(date +%Y%m%d_%H_%M_%S) \n" >> $logfile
        exit 1
fi
