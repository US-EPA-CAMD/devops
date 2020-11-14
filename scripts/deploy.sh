#!/bin/bash

if [ $DEPLOY_FROM_ARTIFACT ]
then
  cd $GITHUB_WORKSPACE

  echo "Retrieving deployment artifacts service key..."
  S3_CREDENTIALS=`cf service-key $CF_ARTIFACTS_SVC $CF_ARTIFACTS_SVC_KEY | tail -n +2`
  export AWS_ACCESS_KEY_ID=`echo "${S3_CREDENTIALS}" | jq -r .access_key_id`
  export AWS_SECRET_ACCESS_KEY=`echo "${S3_CREDENTIALS}" | jq -r .secret_access_key`
  export BUCKET_NAME=`echo "${S3_CREDENTIALS}" | jq -r .bucket`
  export AWS_DEFAULT_REGION=`echo "${S3_CREDENTIALS}" | jq -r '.region'`

  echo "Retrieving package from deployment artifacts..."
  mkdir deployments
  aws s3 cp s3://$BUCKET_NAME/$APP.$VERSION.$GITHUB_RUN_NUMBER.zip deployments/
  cd deployments

  echo "Extracting package..."
  unzip -q $APP.$VERSION.$GITHUB_RUN_NUMBER.zip
fi

echo "Deploying package..."
#cf push
