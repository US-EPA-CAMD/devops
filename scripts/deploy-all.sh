#!/bin/bash

echo "--------------------------------"
echo "-- environment variables -------"
echo "--------------------------------"

export AWS_DEFAULT_REGION="us-gov-west-1"
export CF_API_URL="https://api.fr.cloud.gov"
export CF_ORG_NAME="epa-easey"
export ARTIFACTS_STORAGE="cg-85627a9c-7d48-446a-8cb7-5daa5c694169"

echo "AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION"
echo "CF_API_URL: $CF_API_URL"
echo "CF_ORG_NAME: $CF_ORG_NAME"
echo "ARTIFACTS_STORAGE: $ARTIFACTS_STORAGE"

echo "--------------------------------"
echo "-- secret variables ------------"
echo "--------------------------------"

source secrets.txt

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
        ./scripts/install-cf-cli.sh
else
        echo "cf cli already installed"
        cf version
fi

# ./cf-login.sh

echo "--------------------------------"
echo "-- deploy script ---------------"
echo "--------------------------------"

while read file; do
	./deployProd.sh $file
done <deployList.txt

