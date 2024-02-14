#!/bin/bash

echo "--------------------------------------"
echo "---------- dotnet/build.sh -----------"
echo "--------------------------------------"

echo "Restoring dependencies, building, & publishing..."
cd $1
dotnet publish --configuration Release --self-contained false
