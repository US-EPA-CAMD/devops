#!/bin/bash

echo "CF_USERNAME=$CF_USERNAME"
echo "CF_PASSWORD=$CF_PASSWORD"

echo "Building... "
npm install
npm run build
