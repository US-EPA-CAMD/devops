#!/bin/bash

echo "--------------------------------------"
echo "----------- yarn/build.sh ------------"
echo "--------------------------------------"

echo "Configuring Yarn Offline NPM Package Cache..."
#echo 'yarn-offline-mirror "./npm-packages-offline-cache"' >> .yarnrc
yarn config set yarn-offline-mirror ./npm-packages-offline-cache
#echo 'yarn-offline-mirror-pruning true' >> .yarnrc
yarn config set yarn-offline-mirror-pruning true

echo "Installing dependencies..."
rm -rf node_modules/
yarn install --ignore-engines

echo "Building..."
CI=false yarn build
