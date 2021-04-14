#!/bin/bash

cd $GITHUB_WORKSPACE
ls -h

echo "backup 1 level..."
cd ..
ls -h

echo "Retrieving package from deployment artifacts..."
objectDetails=$(aws s3api  head-object --bucket $ARTIFACTS_STORAGE --key $PACKAGE.zip)
echo $objectDetails

if [[ -z $objectDetails ]];
then
  echo "Error: Package \"$PACKAGE.zip\" doesn't exist in the deployment artifacts @  `date`"
  echo "Exiting deployment stage" 
  exit 1
else
  aws s3 cp s3://$ARTIFACTS_STORAGE/$PACKAGE.zip .
fi

ls -h

echo "Extracting package..."
unzip -q -o -u $PACKAGE.zip
cd $GITHUB_REPOSITORY
ls -h