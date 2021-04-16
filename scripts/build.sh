#!/bin/bash

echo "Installing dependencies..."
npm install

echo "Building..."
CI=false npm run build
