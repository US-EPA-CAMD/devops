#!/bin/bash

echo "--------------------------------------"
echo "----------- yarn/build.sh ------------"
echo "--------------------------------------"

#echo "Installing dependencies..."
#yarn install

#echo "Creating npm-packages-offline-cache..."
#yarn config set yarn-offline-mirror ./npm-packages-offline-cache
#yarn config set yarn-offline-mirror-pruning true
#rm -rf node_modules/ yarn.lock

echo "Installing dependencies..."
yarn install

echo "Building..."
CI=false yarn build
