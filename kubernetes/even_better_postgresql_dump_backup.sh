#!/bin/sh
#
# KUBERNETES compatible backup script.
# requires to be run in an environment with working kubectl

if [ "$3" = "" ]
then
  echo
  echo usage: $0 namespace targetDir dbname [prefix] [retainqty]
  echo
  exit 1
fi

timestamp=$(date +%Y%m%d_%H_%M_%S)
namespace=$1
targetDir=$2
dblist="bds_hub bds_hub_report bdio "
prefix=daily
retainqty=3

# Log file location.
logfile="$targetDir/hub_pgdump.log"

if [[ "$4" != "" ]]
then
        prefix=$4
fi

re='^[0-9]+$'

if [[ $5 =~ $re ]]
then
  retainqty=$5
fi

if [[ "$3" != "" ]] && [[ $dblist == *"${3}"* ]]
then
  dblist=$3
fi

echo $dbname
echo Backup process started at $timestamp
echo Namespace: $namespace
echo Files will be placed into:
for i in $dblist
do
  echo "    $targetDir/${prefix}_${i}_${timestamp}.dump"
done
echo Copies to keep: $retainqty


#Finding the container id
#container_id=$(docker container ls | grep hub-postgres:4.1.0 | awk '{print $1}')
container_id=$(kubectl get pods -n $namespace | awk '/postgres/ {print $1}')

if [ $container_id != "" ]
then
	for i in $dblist
	do
          dumpfile=$targetDir/${prefix}_${i}_${timestamp}.dump
        	echo "Backup $i database into $dumpfile" >> $logfile
        	kubectl exec -i -n $namespace $container_id -- /usr/local/bin/pg_dump -Fc $i  > $dumpfile

        	if [ $? == 0 ]
        	then
                	echo -e "Backup completed at $(date +%Y%m%d_%H_%M_%S) for $i database \n" >> $logfile
        	else
                	echo -e "Backup  failed at $(date +%Y%m%d_%H_%M_%S) \n" >> $logfile
                exit 1
        	fi

    dumpfilepattern=$targetDir/${prefix}_${i}_[0-9]
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
