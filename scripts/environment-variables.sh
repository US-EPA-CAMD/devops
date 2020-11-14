#!/bin/bash

# GLOBAL
echo "CF_API_URL=https://api.fr.cloud.gov" >> $GITHUB_ENV
echo "CF_ORG_NAME=epa-prototyping" >> $GITHUB_ENV
echo "CF_ARTIFACTS_SVC=deployment-artifacts" >> $GITHUB_ENV
echo "CF_ARTIFACTS_SVC_KEY=deployment-artifacts-svc-key" >> $GITHUB_ENV

# DEV
echo "CF_SPACE_NAME=dev-easey-in" >> $GITHUB_ENV

# TEST
#echo "CF_SPACE_NAME=test" >> $GITHUB_ENV

# STAGING
#echo "CF_SPACE_NAME=staging" >> $GITHUB_ENV