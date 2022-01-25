#!/bin/sh
#
# KUBERNETES compatible backup script.
# requires to be run in an environment with working kubectl

if [ "$3" = "" ]
then
  echo
  echo usage: $0 namespace database dumpfile
  echo
  exit 1
fi

namespace=$1
database=$2
dumpfile=$3

echo "Restore process started for $dumpfile into $database "
echo Namespace: $namespace

#Finding the container id
#container_id=$(docker container ls | grep hub-postgres:4.1.0 | awk '{print $1}')
container_id=$(kubectl get pods -n $namespace | awk '/postgres/ {print $1}')

if [ $container_id != "" ]
then
  echo "Processing $dumpfile into $database " 
  cat "${dumpfile}" | kubectl exec -i -n ${namespace} ${container_id} -- pg_restore -Fc --verbose --clean --if-exists -d ${database} 
fi
