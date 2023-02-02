#!/bin/bash
set -eo pipefail

echo "--------------------------------------"
echo "---------- cf-app-init.sh ------------"
echo "--------------------------------------"

if [[ $(cf app $APP_NAME) == *"FAILED"* ]]
then
  echo "$APP_NAME application does not exist! Creating application shell..."
  cf push $APP_NAME --no-manifest --no-route --no-start
else
  echo "$APP_NAME application exists! Skipping application initialization..."
fi
