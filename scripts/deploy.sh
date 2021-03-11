#!/bin/bash

if [ $DEPLOY_FROM_ARTIFACT ]
then
  cd $GITHUB_WORKSPACE

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
  unzip -q $PACKAGE.zip
  cd $APP_NAME
fi

if [ "$CF_ORG_SPACE" != "dev" ]
then
  echo "Installing yq YAML parser..."
  sudo add-apt-repository ppa:rmescandon/yq
  sudo apt update
  sudo apt install yq -y

  echo ""
  echo "Merging manifest-vars.yml and manifest-vars.$CF_ORG_SPACE.yml files..."
  yq m -x manifest-vars.yml manifest-vars.$CF_ORG_SPACE.yml >> manifest-vars.yml
  echo ""  
fi

echo "Using values from manifest-vars.yml..."
echo "{"
cat manifest-vars.yml
echo "}"
echo ""

PREFIX="${APP_NAME/-/_}"
PREFIX="EASEY_${PREFIX^^}"

if [ $REACT_APP ]
then
  PREFIX="REACT_APP_${PREFIX}"
fi

echo "Setting environment variables..."
VERSION_VAR_NAME="${PREFIX}_VERSION"
VERSION_VAR_VALUE="$APP_VERSION.$GITHUB_RUN_NUMBER"

echo "cf set-env $APP_NAME $VERSION_VAR_NAME $VERSION_VAR_VALUE"
cf set-env $APP_NAME $VERSION_VAR_NAME $VERSION_VAR_VALUE

PUBLISHED_VAR_NAME="${PREFIX}_PUBLISHED"
PUBLISHED_VAR_VALUE=$(TZ='America/New_York' date +'%a %b %d %Y')

echo ""
echo "cf set-env $APP_NAME $PUBLISHED_VAR_NAME $PUBLISHED_VAR_VALUE"
cf set-env $APP_NAME $PUBLISHED_VAR_NAME "$PUBLISHED_VAR_VALUE"

echo ""
echo "Deploying package..."
cf push --vars-file manifest-vars.yml
