
#!/bin/bash

if [[ $(cf app $APP_NAME) == *"FAILED"* ]]
then
  echo "$APP_NAME application does not exist! Creating application shell..."
  cf push $APP_NAME --no-manifest --no-route --no-start
fi

if [ "$CF_ORG_SPACE" != "dev" ]
then
  echo "Installing yq YAML parser..."
  wget https://github.com/mikefarah/yq/releases/download/v4.9.8/yq_linux_amd64.tar.gz -O - |\
  tar xz && mv yq_linux_amd64 /usr/bin/yq

  echo ""
  echo "Merging manifest-vars.yml and manifest-vars.$CF_ORG_SPACE.yml files..."
  yq eval-all 'select(fileIndex == 0) * select(filename == "manifest-vars.test.yml")' manifest-vars.yml manifest-vars.test.yml >> manifest-vars.yml
  echo ""  
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
