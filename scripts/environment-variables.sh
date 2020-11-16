#!/bin/bash

# CLOUD.GOV
echo "CF_API_URL=https://api.fr.cloud.gov" >> $GITHUB_ENV
echo "CF_ORG_NAME=epa-easey" >> $GITHUB_ENV

# DEPLOYMENT ARTIFACTS S3 STORAGE
echo "CF_ARTIFACTS_SVC=deployment-artifacts" >> $GITHUB_ENV
echo "CF_ARTIFACTS_SVC_KEY=deployment-artifacts-svc-key" >> $GITHUB_ENV
echo "CF_ARTIFACTS_SVC_SPACE=test" >> $GITHUB_ENV

# DEV
if [ $ENV = "dev" ]
then
  echo "CF_SPACE_NAME=dev" >> $GITHUB_ENV
fi

# TEST
if [ $ENV = "tst" ]
then
  echo "CF_SPACE_NAME=test" >> $GITHUB_ENV
fi

# STAGING
if [ $ENV = "stg" ]
then
  echo "CF_SPACE_NAME=staging" >> $GITHUB_ENV
fi
