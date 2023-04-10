#!/bin/bash
set -eo pipefail

cf target -s $1
cf update-service camd-pg-db -c '{"rotate_credentials": true}'
sleep 0.5

List=(
  "mdm-api"
  "quartz-scheduler"
  "ssh-tunnel"
  "facilities-api"
  "mdm-api"
  "account-api"
  "emissions-api"
  "auth-api"
  "monitor-plan-api"
  "camd-services"
  "qa-certification-api"
  "streaming-services"
)

for app in ${List[*]}
do
   echo "Rotating credentials for $app..."
   ./rotate-credential.sh $app &
   sleep 0.1
done

wait
echo "All done"