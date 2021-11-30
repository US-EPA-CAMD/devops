#!/bin/bash

echo "--------------------------------------"
echo "---------- cf-app-init.sh ------------"
echo "--------------------------------------"

if [[ $(cf app $APP_NAME) == *"FAILED"* ]]
then
  echo "$APP_NAME application does not exist! Creating application shell..."
  cf push $APP_NAME --no-manifest --no-route --no-start
fi
