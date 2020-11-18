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

echo "Copying package to deployment artifacts..."
aws s3 cp $APP.$VERSION.$GITHUB_RUN_NUMBER.zip s3://$ARTIFACTS_STORAGE/
aws s3 ls s3://$ARTIFACTS_STORAGE/$APP.$VERSION
