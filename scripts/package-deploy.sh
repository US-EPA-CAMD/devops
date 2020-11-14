#!/bin/bash

cd $GITHUB_WORKSPACE

echo "Retrieving cloud.gov keys ..."
cf api  $CF_API_URL
cf auth
cf target -o $CF_ORG_NAME -s $CF_SPACE_NAME

S3_CREDENTIALS=`cf service-key $CF_ARTIFACTS_SVC $CF_ARTIFACTS_SVC_KEY | tail -n +2`
export AWS_ACCESS_KEY_ID=`echo "${S3_CREDENTIALS}" | jq -r .access_key_id`
export AWS_SECRET_ACCESS_KEY=`echo "${S3_CREDENTIALS}" | jq -r .secret_access_key`
export BUCKET_NAME=`echo "${S3_CREDENTIALS}" | jq -r .bucket`
export AWS_DEFAULT_REGION=`echo "${S3_CREDENTIALS}" | jq -r '.region'`

mkdir deployments
aws s3 cp s3://$BUCKET_NAME/$3.$4.$5.zip deployments/
cd deployments
unzip -q $3.$4.$5.zip
#ls -l 
#cd $3/starter-kit
cf push
