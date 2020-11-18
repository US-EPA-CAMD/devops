#!/bin/bash

echo "Installing dependencies...npm"
npm install

if [ $NESTJS_APP ]
then
  echo "Building..."
  npm run build
fi
