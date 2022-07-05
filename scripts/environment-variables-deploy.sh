#!/bin/bash

echo "--------------------------------------"
echo "-- environment-variables-noTags.sh ---"
echo "--------------------------------------"

echo "Initialing & Configuring environment..."
echo "Environment: $ENV"

name=$(grep -w name manifest-vars.yml | cut -d':' -f2 | xargs)
echo "APP_NAME=$name" >> $GITHUB_ENV
echo "ENV_VAR_PREFIX=$ENV_VAR_PREFIX" >> $GITHUB_ENV
export AWS_DEFAULT_REGION='us-gov-west-1'
echo "AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION" >> $GITHUB_ENV
echo "CF_API_URL=https://api.fr.cloud.gov" >> $GITHUB_ENV
echo "CF_ORG_NAME=epa-easey" >> $GITHUB_ENV
artifacts_storage='cg-85627a9c-7d48-446a-8cb7-5daa5c694169'
echo "ARTIFACTS_STORAGE=$artifacts_storage" >> $GITHUB_ENV

# version=$(grep sonar.projectVersion sonar-project.properties | cut -d'=' -f2)
# version=$version.$GITHUB_RUN_NUMBER
if [[ $PACKAGE == "latest" ]]; then
  PACKAGE = $(aws s3api list-objects --bucket $artifacts_storage --prefix $name --output text --query 'Contents[].{Key: Key}' | tail -n1)
fi
echo "PACKAGE=$PACKAGE" >> $GITHUB_ENV
echo "Package: $PACKAGE"
echo ""

case $ENV in
  (CDC)
    echo "CF_ORG_SPACE=cdc" >> $GITHUB_ENV
    echo "CF_ORG_SPACE=cdc"
    ;;
  (Beta)
    echo "CF_ORG_SPACE=beta" >> $GITHUB_ENV
    echo "CF_ORG_SPACE=beta"
    ;;
  (Test)
    echo "CF_ORG_SPACE=test" >> $GITHUB_ENV
    echo "CF_ORG_SPACE=test"
    ;;
  (Staging)
    echo "CF_ORG_SPACE=staging" >> $GITHUB_ENV
    echo "CF_ORG_SPACE=staging"
    ;;
  # This is to match case of no tag for dev env as we do not want a malformed tag pushing to dev
  "")
    echo "CF_ORG_SPACE=dev" >> $GITHUB_ENV
    echo "CF_ORG_SPACE=dev"
    ;;
  # if nothing matches we need to error and exit since the CF_ORG_SPACE is not properly set
  *)
    echo "ERROR: Unknown environment, cannot  properly set the CF_ORG_SPACE env var!"
    exit 1
    ;;
esac
