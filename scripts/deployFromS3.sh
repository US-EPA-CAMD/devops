#!/bin/bash

cd $GITHUB_WORKSPACE

echo "Retrieving keys ..."
cf api  https://api.fr.cloud.gov
cf auth $1 $2
cf target -o "epa-prototyping" -s "dev-easey-in"

# S3_CREDENTIALS=`cf service-key "${SERVICE_INSTANCE_NAME}" "${KEY_NAME}" | tail -n +2`
S3_CREDENTIALS=`cf service-key "deployment-artifacts" "deployment-artifacts-svc-key" | tail -n +2`
export AWS_ACCESS_KEY_ID=`echo "${S3_CREDENTIALS}" | jq -r .access_key_id`
export AWS_SECRET_ACCESS_KEY=`echo "${S3_CREDENTIALS}" | jq -r .secret_access_key`
export BUCKET_NAME=`echo "${S3_CREDENTIALS}" | jq -r .bucket`
export AWS_DEFAULT_REGION=`echo "${S3_CREDENTIALS}" | jq -r '.region'`

mkdir deployments
aws s3 cp  s3://cg-2f1f8ec0-a961-4d0b-af39-2ed9f109078e/$3.$4.$5.zip deployments/
cd deployments
unzip -q $3.$4.$5.zip
ls -l 
cd $3/starter-kit
cf push

