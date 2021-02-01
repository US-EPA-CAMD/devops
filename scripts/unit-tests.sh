#!/bin/bash

if [ $NESTJS_APP ]
then
  echo "Installing Jest framework..."
  npm install jest

  echo "Running Unit tests... "
  npm run test
fi

if [ $REACT_APP ]
then
  echo "Installing React scripts..."
  npm install react-scripts

  echo "Running Unit tests... "
  CI=true npm run test:cov
  sed -e 's|SF:'`pwd`'|SF:|' covergae/lcov.info
  cat coverage/lcov.info
fi