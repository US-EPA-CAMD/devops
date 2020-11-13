#!/bin/bash

echo "CF_API_URL=$CF_API_URL"

echo "Building... "
npm install
npm run build
