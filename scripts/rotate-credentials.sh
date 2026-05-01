#!/bin/bash
set -eo pipefail

cf target -s $1
cf update-service camd-pg-db -c '{"rotate_credentials": true}'
echo "Waiting 2 minutes for rotate credentials to finish... "
sleep 120

List=(
  "mdm-api"
  "quartz-scheduler"
  "ssh-tunnel"
  "facilities-api"
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
   ./rotate-credential.sh $app
done

echo "All done"