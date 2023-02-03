#!/bin/bash
set -eo pipefail

echo "--------------------------------------"
echo "----------- yarn/build.sh ------------"
echo "--------------------------------------"

echo "Configuring Yarn Offline NPM Package Cache..."
yarn config set yarn-offline-mirror ./npm-packages-offline-cache
echo 'yarn-offline-mirror "./npm-packages-offline-cache"' >> .yarnrc
yarn config set yarn-offline-mirror-pruning true
echo 'yarn-offline-mirror-pruning true' >> .yarnrc

echo "Installing dependencies..."
rm -rf node_modules/ yarn.lock
yarn install --ignore-engines

echo "Building..."
CI=false yarn build

echo "App root contents..."
ls -al

echo "Yarn offline cache contents..."
cd npm-packages-offline-cache/
ls -al
cd ..
