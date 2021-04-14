#!/bin/bash

cd $GITHUB_WORKSPACE

echo "Retrieving app, version, and build #..."
echo "App Name: $APP_NAME"
echo "App Version: $APP_VERSION"
echo "Build #: $GITHUB_RUN_NUMBER"
echo ""

echo "Building Artifact: $APP_NAME.$APP_VERSION.$GITHUB_RUN_NUMBER.zip"
cd ../
zip -q -r $APP_NAME.$APP_VERSION.$GITHUB_RUN_NUMBER.zip `basename $GITHUB_WORKSPACE` -x */\.* *.git* \.* *.md *Docker* *docker* LICENSE /node_modules/* /test/*
ls -l $APP_NAME.$APP_VERSION.$GITHUB_RUN_NUMBER.zip
echo ""

echo "Copying package to deployment artifacts..."
aws s3 cp $APP_NAME.$APP_VERSION.$GITHUB_RUN_NUMBER.zip s3://$ARTIFACTS_STORAGE/
aws s3 ls s3://$ARTIFACTS_STORAGE/$APP_NAME.$APP_VERSION
echo ""