#!/bin/bash

if [[ $(cf app $APP_NAME) == *"FAILED"* ]]
then
  echo "$APP_NAME application does not exist! Creating application shell..."
  cf push $APP_NAME --no-manifest --no-route --no-start
fi

if [ "$CF_ORG_SPACE" != "dev" ]
then
  cp manifest-vars.$CF_ORG_SPACE.yml manifest-vars.yml
  echo "Using manifest-vars.${CF_ORG_SPACE}.yml"
  cat manifest-vars.yml
fi

PREFIX="${ENV_VAR_PREFIX}_${APP_NAME//-/_}"

echo "Setting environment variables..."
VERSION_VAR_NAME="${PREFIX^^}_VERSION"
VERSION_VAR_VALUE="$APP_VERSION"

echo "cf set-env $APP_NAME $VERSION_VAR_NAME $VERSION_VAR_VALUE"
cf set-env $APP_NAME $VERSION_VAR_NAME $VERSION_VAR_VALUE

PUBLISHED_VAR_NAME="${PREFIX^^}_PUBLISHED"
PUBLISHED_VAR_VALUE=$(TZ='America/New_York' date +'%a %b %d %Y')

echo ""
echo "cf set-env $APP_NAME $PUBLISHED_VAR_NAME $PUBLISHED_VAR_VALUE"
cf set-env $APP_NAME $PUBLISHED_VAR_NAME "$PUBLISHED_VAR_VALUE"

echo ""
echo "Deploying package..."
cf push --vars-file manifest-vars.yml
