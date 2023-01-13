#!/bin/bash

echo "--------------------------------------"
echo "-- environment-variables-noTags.sh ---"
echo "--------------------------------------"

echo "Initialing & Configuring environment..."
echo "Environment: $1"

name=$(grep -w name manifest-vars.yml | cut -d':' -f2 | xargs)
echo "APP_NAME=$name" >> $GITHUB_ENV
echo "ENV_VAR_PREFIX=$ENV_VAR_PREFIX" >> $GITHUB_ENV
echo "AWS_DEFAULT_REGION=us-gov-west-1" >> $GITHUB_ENV
echo "CF_API_URL=https://api.fr.cloud.gov" >> $GITHUB_ENV
echo "CF_ORG_NAME=epa-easey" >> $GITHUB_ENV
echo "ARTIFACTS_STORAGE=cg-85627a9c-7d48-446a-8cb7-5daa5c694169" >> $GITHUB_ENV

version=$(grep sonar.projectVersion sonar-project.properties | cut -d'=' -f2)
version=$version.$GITHUB_RUN_NUMBER
echo "APP_VERSION=$version" >> $GITHUB_ENV
echo "App Version: $version"
echo ""


echo "PACKAGE=$name.$version" >> $GITHUB_ENV
echo "Package: $name.$version"
echo ""

case $1 in
  (CDC)
    echo "CF_ORG_SPACE=cdc" >> $GITHUB_ENV
    echo "CF_ORG_SPACE=cdc"
    ;;
  (BETA)
    echo "CF_ORG_SPACE=beta" >> $GITHUB_ENV
    echo "CF_ORG_SPACE=beta"
    ;;
  (TEST)
    echo "CF_ORG_SPACE=test" >> $GITHUB_ENV
    echo "CF_ORG_SPACE=test"
    ;;
  (STAGE)
    echo "CF_ORG_SPACE=staging" >> $GITHUB_ENV
    echo "CF_ORG_SPACE=staging"
    ;;
  (PERF)
    echo "CF_ORG_SPACE=perf" >> $GITHUB_ENV
    echo "CF_ORG_SPACE=perf"
    ;;
  (PROD)
    echo "CF_ORG_SPACE=prod" >> $GITHUB_ENV
    echo "CF_ORG_SPACE=prod"
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
