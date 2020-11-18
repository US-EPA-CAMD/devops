#!/bin/bash

echo "Checking for tag..."

# The following examples are valid TAG formats...
# tst-1.0.101, stg-1.0.101, tstrbk-1.0.101, stgrbk-1.0.101
tag=$(git tag --points-at HEAD)

case $tag in
  (tst-[0-9]*.[0-9]*.[0-9]*)
    echo "CF_ORG_SPACE=test" >> $GITHUB_ENV
    ;;
  (stg-[0-9]*.[0-9]*.[0-9]*)
    echo "CF_ORG_SPACE=staging" >> $GITHUB_ENV
    ;;
  # This is to match case of no tag for dev env as we do not want a malformed tag pushing to dev
  "")
    echo "CF_ORG_SPACE=dev" >> $GITHUB_ENV
    ;;
  # if nothing matches we need to error and exit since the CF_ORG_SPACE is not properly set
  *)
    echo "ERROR: TAG was not in the proper format to properly set the CF_ORG_SPACE env var!"
    exit 1
    ;;
esac
