#!/bin/bash
set -eo pipefail

echo "--------------------------------------"
echo "------------ cf-login.sh -------------"
echo "--------------------------------------"

echo "Initiating cloud.gov login... "
cf api $CF_API_URL

echo ""
cf auth

echo ""
echo "Setting cloud.gov target organization and space... "
cf target -o $CF_ORG_NAME -s $CF_ORG_SPACE
