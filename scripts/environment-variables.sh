#!/bin/bash

echo "Initialing & Configuring environment..."
echo ""

name=$(grep name manifest-vars.yml | cut -d':' -f2 | xargs)
echo "APP_NAME=$name" >> $GITHUB_ENV
echo "ENV_VAR_PREFIX=$ENV_VAR_PREFIX" >> $GITHUB_ENV
echo "AWS_DEFAULT_REGION=us-gov-west-1" >> $GITHUB_ENV
echo "CF_API_URL=https://api.fr.cloud.gov" >> $GITHUB_ENV
echo "CF_ORG_NAME=epa-easey" >> $GITHUB_ENV
echo "ARTIFACTS_STORAGE=cg-85627a9c-7d48-446a-8cb7-5daa5c694169" >> $GITHUB_ENV

echo "Retrieving tag & version..."
tag=$(git tag --points-at HEAD)

if [ "$tag" != "" ]
then
  echo "Tag: $tag"
  echo ""
  version=$(echo $tag | cut -d'-' -f2)
  echo "APP_VERSION=$version" >> $GITHUB_ENV
  echo "App Version: $version"
  echo ""
else
  echo "Tag not provided will retrieve version from project properties..."
  version=$(grep sonar.projectVersion sonar-project.properties | cut -d'=' -f2)
  version=$version.$GITHUB_RUN_NUMBER
  echo "APP_VERSION=$version" >> $GITHUB_ENV
  echo "App Version: $version"
  echo ""
fi

echo "PACKAGE=$name.$version" >> $GITHUB_ENV

case $tag in
  (tst-v[0-9]*.[0-9]*)
    echo "CF_ORG_SPACE=test" >> $GITHUB_ENV
    echo "CF_ORG_SPACE=test"
    ;;
  (rbktst-v[0-9]*.[0-9]*)
    echo "CF_ORG_SPACE=test" >> $GITHUB_ENV
    echo "CF_ORG_SPACE=test"
    ;;
  (rbkstg-v[0-9]*.[0-9]*)
    echo "CF_ORG_SPACE=staging" >> $GITHUB_ENV
    echo "CF_ORG_SPACE=staging"
    ;;
  (stg-v[0-9]*.[0-9]*)
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
    echo "ERROR: TAG was not in the proper format to properly set the CF_ORG_SPACE env var!"
    exit 1
    ;;
esac
