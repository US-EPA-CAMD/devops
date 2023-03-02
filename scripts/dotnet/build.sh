#!/bin/bash

echo "--------------------------------------"
echo "---------- dotnet/build.sh -----------"
echo "--------------------------------------"

echo "Installing dependencies..."
dotnet restore

echo "Building..."
CI=false dotnet build -c Release
