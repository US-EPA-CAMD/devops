#!/bin/bash

echo "--------------------------------"
echo "-- environment variables -------"
echo "--------------------------------"

echo "Initialing & Configuring environment"

export ENV_VAR_PREFIX=$1
echo "ENV_VAR_PREFIX: $ENV_VAR_PREFIX"
shift

export APP_NAME=$2
echo "App Name: $APP_NAME"

export APP_VERSION=$1
echo "App Version: $APP_VERSION"

export PACKAGE=$APP_NAME.$APP_VERSION
echo "Package: $PACKAGE"

# source ./devops/scripts/secrets.txt
echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID"
echo "AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY"

mkdir $APP_NAME
cd $APP_NAME

../devops/scripts/download-artifact.sh

../devops/scripts/cf-app-init.sh

echo "--------------------------------"
echo "-- environment secret ----------"
echo "--------------------------------"

../devops/scripts/$APP_NAME/configure-env-vars-secrets.sh

../devops/scripts/deploy.sh



echo "--------------------------------"
echo "-- clean up --------------------"
echo "--------------------------------"

cd ..
rm -rf $APP_NAME

