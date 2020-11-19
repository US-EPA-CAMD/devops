#!/bin/bash

if [ $DEPLOY_FROM_ARTIFACT ]
then
  cd $GITHUB_WORKSPACE

  echo "Retrieving package from deployment artifacts..."
  aws s3 cp s3://$ARTIFACTS_STORAGE/$PACKAGE.zip .

  echo "Extracting package..."
  unzip -q $PACKAGE.zip
  cd $APP_NAME
fi

echo "Deploying package..."
cf push -f manifest.$CF_ORG_SPACE.yml