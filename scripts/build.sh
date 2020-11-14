#!/bin/bash

echo "CF_ORG_NAME=$CF_ORG_NAME"
echo "CF_SPACE_NAME=$CF_SPACE_NAME"
echo "CF_API_URL=$CF_API_URL"

echo "Building... "
npm install
npm run build
