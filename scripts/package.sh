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
cf api  $CF_API_URL
cf auth
cf target -o $CF_ORG_NAME -s $CF_SPACE_NAME

S3_CREDENTIALS=`cf service-key $CF_ARTIFACTS_SVC $CF_ARTIFACTS_SVC_KEY | tail -n +2`
export AWS_ACCESS_KEY_ID=`echo "${S3_CREDENTIALS}" | jq -r .access_key_id`
export AWS_SECRET_ACCESS_KEY=`echo "${S3_CREDENTIALS}" | jq -r .secret_access_key`
export BUCKET_NAME=`echo "${S3_CREDENTIALS}" | jq -r .bucket`
export AWS_DEFAULT_REGION=`echo "${S3_CREDENTIALS}" | jq -r '.region'`

aws s3 cp $APP.$VERSION.$GITHUB_RUN_NUMBER.zip s3://$BUCKET_NAME/
aws s3 ls s3://$BUCKET_NAME/
