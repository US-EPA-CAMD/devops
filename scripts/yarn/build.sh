#!/bin/bash

echo "--------------------------------------"
echo "----------- yarn/build.sh ------------"
echo "--------------------------------------"

echo "Config Offline Yarn Registry Cache..."
yarn config set yarn-offline-mirror ./npm-packages-offline-cache
yarn config set yarn-offline-mirror-pruning true
rm -rf node_modules/ yarn.lock

echo "Installing dependencies..."
yarn install --ignore-engines

echo "Building..."
CI=false yarn build
