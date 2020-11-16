#!/bin/bash

echo "Installing dependencies..."
npm install

if [ $NESTJS_APP ]
then
  echo "Building..."
  npm run build
fi