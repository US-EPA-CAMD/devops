#!/bin/bash
set -eo pipefail

echo "--------------------------------------"
echo "------- download-artifcat.sh ---------"
echo "--------------------------------------"

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

echo "Extracting package..."
unzip -q -o -u $PACKAGE.zip
rm $PACKAGE.zip

echo "App root contents..."
ls -al

DIR="./npm-packages-offline-cache"
if [ -d "$DIR" ]; then
  echo "Yarn offline cache contents..."
  cd $DIR
  ls -al
  cd ..
fi
