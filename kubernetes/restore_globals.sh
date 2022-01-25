#!/bin/sh
#
# KUBERNETES compatible backup script.
# requires to be run in an environment with working kubectl

if [ "$2" = "" ]
then
  echo
  echo usage: $0 namespace globalsfile
  echo
  exit 1
fi

namespace=$1
globalsfile=$2

echo Restore globals process started 
echo Namespace: $namespace

#Finding the container id
#container_id=$(docker container ls | grep hub-postgres:4.1.0 | awk '{print $1}')
container_id=$(kubectl get pods -n $namespace | awk '/postgres/ {print $1}')

if [ $container_id != "" ]
then
  echo "Processing globals $globalsfile " 
  cat $globalsfile | kubectl exec -i -n $namespace $container_id -- psql -d postgres
fi
