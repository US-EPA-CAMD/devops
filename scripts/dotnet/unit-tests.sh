#!/bin/bash

echo "--------------------------------------"
echo "-------- dotnet/unit-tests.sh --------"
echo "--------------------------------------"

echo "Running Unit tests... "
CI=true dotnet run tests
sed -i.bak 's|SF:'`pwd`'|SF:/github/workspace/|' coverage/lcov.info