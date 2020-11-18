#!/bin/bash

if [ $DEPLOY_FROM_ARTIFACT ]
then
  cd $GITHUB_WORKSPACE

  echo "Retrieving package from deployment artifacts..."
  mkdir deployments
  aws s3 cp s3://$ARTIFACTS_STORAGE/$APP.$VERSION.$GITHUB_RUN_NUMBER.zip deployments/
  cd deployments

  echo "Extracting package..."
  unzip -q $APP.$VERSION.$GITHUB_RUN_NUMBER.zip
fi

echo "Deploying package..."
cf push
