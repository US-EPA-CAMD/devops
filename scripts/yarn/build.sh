#!/bin/bash

echo "--------------------------------------"
echo "----------- yarn/build.sh ------------"
echo "--------------------------------------"

echo "Installing dependencies..."
yarn install --ignore-engines

echo "Building..."
CI=false yarn build
