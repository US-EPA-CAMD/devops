#!/bin/bash

cd $GITHUB_WORKSPACE
VERSION=$(grep sonar.projectVersion sonar-project.properties | cut -d'=' -f2)
APP=$(echo $GITHUB_REPOSITORY|cut -d'/' -f2)

echo "App Version: $VERSION"
echo "App Name: $APP"
echo "Build Artifact: $APP.$VERSION.$GITHUB_RUN_NUMBER"
cd ../
zip -q -x \*.git* -r $APP.$VERSION.$GITHUB_RUN_NUMBER.zip `basename $GITHUB_WORKSPACE`
ls -lh $APP.$VERSION.$GITHUB_RUN_NUMBER.zip

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

aws s3 cp $APP.$VERSION.$GITHUB_RUN_NUMBER.zip s3://cg-2f1f8ec0-a961-4d0b-af39-2ed9f109078e/
aws s3 ls s3://cg-2f1f8ec0-a961-4d0b-af39-2ed9f109078e/
