#!/bin/bash

echo "Retrieving tag..."
tag=$(git tag --points-at HEAD)
echo "Tag: $tag"

if [ "$tag" != "" ]
then
  echo "Parsing tag version..."
  version=$(echo $tag | cut -d'-' -f2)
  echo "Version: $version"
  echo "PACKAGE: $APP_NAME.$version"
  echo "PACKAGE=$APP_NAME.$version" >> $GITHUB_ENV
fi

case $tag in
  (tst-v[0-9]*.[0-9]*)
    echo "CF_ORG_SPACE=test" >> $GITHUB_ENV
    echo "CF_ORG_SPACE=test"
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
