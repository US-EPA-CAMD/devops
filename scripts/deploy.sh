#!/bin/bash

if [ $DEPLOY_FROM_ARTIFACT ]
then
  cd $GITHUB_WORKSPACE

  echo "Retrieving package from deployment artifacts..."
  objectDetails=$(aws s3api  head-object --bucket $ARTIFACTS_STORAGE --key $PACKAGE.zip)
  echo "---------"
  echo $objectDetails
  echo "---------"
  if [[ -z $objectDetails ]]; then
   aws s3 cp s3://$ARTIFACTS_STORAGE/$PACKAGE.zip .
  else
   echo "Error: Package doesnt exist on S3"
   exit 1
  fi

  echo "Extracting package..."
  unzip -q $PACKAGE.zip
  cd $APP_NAME
fi

echo "Deploying package..."
cf push -f manifest.$CF_ORG_SPACE.yml
