#!/bin/bash

if [ $DEPLOY_FROM_ARTIFACT ]
then
  cd $GITHUB_WORKSPACE

  echo "Retrieving package from deployment artifacts..."
  mkdir deployments
  aws s3 cp s3://$ARTIFACTS_STORAGE/$PACKAGE.zip deployments/
  cd deployments
  ls -l

  echo "Extracting package..."
  unzip -q $PACKAGE.zip
  ls -l  
fi

echo "Deploying package..."
cf push -f manifest.$CF_ORG_SPACE.yml