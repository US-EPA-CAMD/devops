#!/bin/bash

echo "--------------------------------------"
echo "----------- yarn/build.sh ------------"
echo "--------------------------------------"

echo "Configuring Yarn Offline NPM Package Cache..."
yarn config set yarn-offline-mirror ./npm-packages-offline-cache
echo 'yarn-offline-mirror "./npm-packages-offline-cache"' >> .yarnrc
yarn config set yarn-offline-mirror-pruning true
echo 'yarn-offline-mirror-pruning true' >> .yarnrc

echo "Installing dependencies..."
rm -rf node_modules/
yarn install --ignore-engines

echo "Building..."
CI=false yarn build

ls -al
cd npm-packages-offline-cache
ls -al
