#!/bin/bash

echo "Deploying to cloud.gov... "
cf api  $CF_API_URL
cf auth
cf target -o $CF_ORG_NAME -s $CF_SPACE_NAME
#cf push