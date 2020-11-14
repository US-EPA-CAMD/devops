#!/bin/bash

cd $GITHUB_WORKSPACE

echo "Retrieving app, version, and build #..."
APP=$(echo $GITHUB_REPOSITORY | cut -d'/' -f2)
VERSION=$(grep sonar.projectVersion sonar-project.properties | cut -d'=' -f2)

echo "App Name: $APP"
echo "App Version: $VERSION"
echo "Build #: $GITHUB_RUN_NUMBER"

echo "Building Artifact: $APP.$VERSION.$GITHUB_RUN_NUMBER.zip"
cd ../
zip -q -x \*.git* -r $APP.$VERSION.$GITHUB_RUN_NUMBER.zip `basename $GITHUB_WORKSPACE`
ls -lh $APP.$VERSION.$GITHUB_RUN_NUMBER.zip

echo "Retrieving deployment artifacts service key..."
S3_CREDENTIALS=`cf service-key $CF_ARTIFACTS_SVC $CF_ARTIFACTS_SVC_KEY | tail -n +2`
export AWS_ACCESS_KEY_ID=`echo "${S3_CREDENTIALS}" | jq -r .access_key_id`
export AWS_SECRET_ACCESS_KEY=`echo "${S3_CREDENTIALS}" | jq -r .secret_access_key`
export BUCKET_NAME=`echo "${S3_CREDENTIALS}" | jq -r .bucket`
export AWS_DEFAULT_REGION=`echo "${S3_CREDENTIALS}" | jq -r '.region'`

echo "Copying package to deployment artifacts..."
aws s3 cp $APP.$VERSION.$GITHUB_RUN_NUMBER.zip s3://$BUCKET_NAME/
aws s3 ls s3://$BUCKET_NAME/
