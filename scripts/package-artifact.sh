#!/bin/bash
set -eo pipefail

echo "--------------------------------------"
echo "-------- package-artifact.sh ---------"
echo "--------------------------------------"

echo "Retrieving app, version, and build #..."
echo "App Name: $APP_NAME"
echo "App Version: $APP_VERSION"
echo "Build #: $GITHUB_RUN_NUMBER"
echo ""

echo "App root contents..."
ls -al

echo "Yarn offline cache contents..."
cd npm-packages-offline-cache/
ls -al
cd ..

echo "Building Artifact: $PACKAGE.zip"
zip -q -r $PACKAGE.zip . -x '.env*' '.git/*' '.scannerwork/*' 'coverage/*' 'devops/*' 'node_modules/*'
echo ""

echo "Copying package to deployment artifacts..."
aws s3 cp $PACKAGE.zip s3://$ARTIFACTS_STORAGE/
aws s3 ls s3://$ARTIFACTS_STORAGE/$APP_NAME.$APP_VERSION
echo ""
