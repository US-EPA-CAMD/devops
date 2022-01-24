#!/bin/bash

echo "--------------------------------"
echo "-- environment variables -------"
echo "--------------------------------"

echo "Initialing & Configuring environment"

ENV_VAR_PREFIX=$1
echo "ENV_VAR_PREFIX: $ENV_VAR_PREFIX"
shift

APP_NAME=$2
echo "App Name: $APP_NAME"

APP_VERSION=$1
echo "App Version: $APP_VERSION"

PACKAGE=$APP_NAME.$APP_VERSION
echo "Package: $PACKAGE"

CF_ORG_SPACE="prod"
echo "CF_ORG_SPACE=prod"

ENV_VAR_PREFIX="REACT_APP_EASEY"
echo "ENV_VAR_PREFIX: $ENV_VAR_PREFIX"

source secrets.txt
echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID"
echo "AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY"

# ./download-artifact.sh

# ./cf-app-init.sh

echo "--------------------------------"
echo "-- environment secret ----------"
echo "--------------------------------"
	
while [ $# -gt 2 ]
do
	shift 2
	echo "cf set-env #APP_NAME $1 $2" 
	# cf set-env #APP_NAME 
done

# ./deploy.sh
