#!/bin/bash

echo "--------------------------------------"
echo "----------- yarn/build.sh ------------"
echo "--------------------------------------"

echo "Configuring Yarn Offline NPM Package Cache..."
echo 'yarn-offline-mirror "./npm-packages-offline-cache"' >> .yarnrc
echo 'yarn-offline-mirror-pruning true' >> .yarnrc

echo "Installing dependencies..."
yarn install --ignore-engines

echo "Building..."
CI=false yarn build
