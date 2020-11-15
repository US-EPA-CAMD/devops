#!/bin/bash

echo "Build steps here... "

echo "Building React Web App... "
cd starter-kit/app
npm install
cd ../..

echo "Building facilities api... "
cd starter-kit/facilities-api
npm install
npm run build
cd ../..

echo "Building posts api... "
cd starter-kit/posts-api
npm install
cd ../..

echo "Building tasks api... "
cd starter-kit/tasks-api
npm install
npm run build
cd ../..