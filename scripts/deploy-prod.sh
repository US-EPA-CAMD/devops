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

case $APP_NAME in 

	campd-ui)
		echo "cf set-env $APP_NAME REACT_APP_CAMPD_API_KEY $REACT_APP_CAMPD_API_KEY"
		;;

	other-api)
		echo "cf set-env $APP_NAME API_KEY $API_KEY"
		;;

	*)
		;;
esac
	
# while [ $# -gt 2 ]
# do
# 	shift 2
# 	echo "cf set-env $APP_NAME $1 $2" 
# 	# cf set-env $APP_NAME 
# done

./devops/scripts/deploy.sh



echo "--------------------------------"
echo "-- clean up --------------------"
echo "--------------------------------"

cd ..
rm -rf $APP_NAME

