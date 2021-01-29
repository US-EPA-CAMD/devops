#!/bin/bash

if [ $DEPLOY_FROM_ARTIFACT ]
then
  cd $GITHUB_WORKSPACE

  echo "Retrieving package from deployment artifacts..."
  objectDetails=$(aws s3api  head-object --bucket $ARTIFACTS_STORAGE --key $PACKAGE.zip)
  echo $objectDetails
  if [[ -z $objectDetails ]]; then
   echo "Error: Package \"$PACKAGE.zip\" doesn't exist in the deployment artifacts @  `date`"
   echo "Exiting deployment stage" 
   exit 1
  else
   aws s3 cp s3://$ARTIFACTS_STORAGE/$PACKAGE.zip .
  fi

  echo "Extracting package..."
  unzip -q $PACKAGE.zip
  cd $APP_NAME
fi

echo "Deploying package..."
echo "DEBUG: START"
ls -l 
pwd
ls -l manifest-vars.$CF_ORG_SPACE.yml
echo "DEBUG: END"
cf push --vars-file manifest-vars.$CF_ORG_SPACE.yml
