#!/bin/bash

echo "CF_API_URL=$CF_API_URL"

echo "Run Unit tests ... "
npm install jest
npm run test