#!/bin/bash

echo "Running Unit tests... "
CI=true npm run test
sed -i.bak 's|SF:'`pwd`'|SF:/github/workspace/|' coverage/lcov.info