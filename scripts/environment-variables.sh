#!/bin/bash

# AWS GOV CLOUD
echo "AWS_DEFAULT_REGION=us-gov-west-1" >> $GITHUB_ENV

# CLOUD.GOV
echo "CF_API_URL=https://api.fr.cloud.gov" >> $GITHUB_ENV
echo "CF_ORG_NAME=epa-easey" >> $GITHUB_ENV

# AWS S3 ARTIFACTS STORAGE
echo "ARTIFACTS_STORAGE=cg-85627a9c-7d48-446a-8cb7-5daa5c694169" >> $GITHUB_ENV
