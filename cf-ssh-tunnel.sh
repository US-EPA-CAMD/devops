#!/bin/bash

echo ""
echo "Using the following parameters..."

while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
        echo "$param=$2"
   fi

  shift
done

echo ""

cf api https://api.fr.cloud.gov
cf auth
cf target -o $organization -s $space

echo ""
echo "Establishing SSH tunnel..."
cf ssh $application -L $localPort:$host:$remotePort
