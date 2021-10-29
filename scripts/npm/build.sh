#!/bin/bash

echo "--------------------------------------"
echo "----------- npm/build.sh ------------"
echo "--------------------------------------"

echo "Installing dependencies..."
npm install

echo "Building..."
CI=false npm run build
