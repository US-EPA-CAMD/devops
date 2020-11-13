#!/bin/bash

echo "Deploying to cloud.gov... "
cf api  $1
cf auth $2 $3
cf target -o $4 -s $5
cf push