#!/bin/bash

echo "Deploy steps here ... "
cf api  https://api.fr.cloud.gov
cf auth $1 $2
cf target -o "epa-prototyping" -s "dev-easey-in"
cd starter-kit
cf push

