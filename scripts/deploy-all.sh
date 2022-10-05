#!/bin/bash

pwd

echo "--------------------------------"
echo "-- environment variables -------"
echo "--------------------------------"

export AWS_DEFAULT_REGION="us-gov-west-1"
export CF_API_URL="https://api.fr.cloud.gov"
export CF_ORG_NAME="epa-easey"
export CF_ORG_SPACE="prod"
export ARTIFACTS_STORAGE="cg-85627a9c-7d48-446a-8cb7-5daa5c694169"

echo "AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION"
echo "CF_API_URL: $CF_API_URL"
echo "CF_ORG_NAME: $CF_ORG_NAME"
echo "CF_ORG_SPACE: $CF_ORG_SPACE"
echo "ARTIFACTS_STORAGE: $ARTIFACTS_STORAGE"

echo "--------------------------------"
echo "-- secret variables ------------"
echo "--------------------------------"

source ./devops/scripts/secrets.txt

echo "CF_USERNAME: $CF_USERNAME"
echo "CF_PASSWORD: $CF_PASSWORD"
echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID"
echo "AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY"

echo "--------------------------------"
echo "-- install cf cli --------------"
echo "--------------------------------"

if ! command -v cf version 
then
        echo "installing cf cli"
        ./devops/scripts/install-cf-cli.sh
else
        echo "cf cli already installed"
        cf version
fi

./devops/scripts/cf-login.sh

echo "--------------------------------"
echo "-- deploy script ---------------"
echo "--------------------------------"

echo "MAKE SURE THERE IS A SPACE AFTER EACH LINE IN deploy-list.txt!!!"

while read file; do
        if [[ ! $file == //* ]]
        then  
	       ./devops/scripts/deploy-prod.sh $file &
        fi
done <./devops/scripts/deploy-list.txt


wait
echo "All done"
