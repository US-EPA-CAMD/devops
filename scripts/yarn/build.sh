#!/bin/bash
set -eo pipefail

echo "--------------------------------------"
echo "----------- yarn/build.sh ------------"
echo "--------------------------------------"

# Runtime environment (Node patch, runner image, memory/disk space).
echo "--- runtime environment ---"
node --version 2>&1 || true
yarn --version 2>&1 || true
echo "ImageOS=${ImageOS:-unknown} ImageVersion=${ImageVersion:-unknown} RUNNER_OS=${RUNNER_OS:-unknown}"
free -h 2>&1 | head -2 || true
df -h / 2>&1 | tail -1 || true
echo "---------------------------"

echo "Configuring Yarn Offline NPM Package Cache..."
yarn config set yarn-offline-mirror ./npm-packages-offline-cache
echo 'yarn-offline-mirror "./npm-packages-offline-cache"' >> .yarnrc
yarn config set yarn-offline-mirror-pruning true
echo 'yarn-offline-mirror-pruning true' >> .yarnrc

echo "Installing dependencies..."
yarn install --ignore-engines

echo "Building..."
# Capture the real exit code of `yarn build` without letting `set -e` short-circuit
set +e
CI=false yarn build 2>&1 | tee build.log
BUILD_EXIT=${PIPESTATUS[0]}
set -e
echo "--- yarn build exit code: $BUILD_EXIT ---"

# Inventory both possible build-output dirs. Backends emit to dist/; UIs emit to build/.
echo "--- build output inventory ---"
if [ -d dist ]; then
  echo "dist/ recursive listing (truncated):"
  ls -laR dist/ 2>&1 | head -100 || true
  echo "dist/ total file count: $(find dist/ -type f 2>/dev/null | wc -l)"
  if [ -f dist/main.js ]; then
    echo "dist/main.js: $(wc -c < dist/main.js) bytes"
  else
    echo "dist/main.js: MISSING"
  fi
fi
if [ -d build ]; then
  echo "build/ top-level listing:"
  ls -la build/ 2>&1 | head -30 || true
  echo "build/ total file count: $(find build/ -type f 2>/dev/null | wc -l)"
fi
echo "------------------------------"

# Abort if `yarn build` failed or produced no output. Don't ship something wrong
if [ "$BUILD_EXIT" -ne 0 ]; then
  echo "FATAL: yarn build exited with code $BUILD_EXIT. Aborting..."
  exit "$BUILD_EXIT"
fi

DIST_FILE_COUNT=$(find dist/ -type f 2>/dev/null | wc -l || echo 0)
BUILD_FILE_COUNT=$(find build/ -type f 2>/dev/null | wc -l || echo 0)
if [ "$DIST_FILE_COUNT" -eq 0 ] && [ "$BUILD_FILE_COUNT" -eq 0 ]; then
  echo "FATAL: build produced no output (both dist/ and build/ are empty/missing). Aborting..."
  exit 1
fi

echo "App root contents..."
ls -al

echo "Yarn offline cache contents..."
cd npm-packages-offline-cache/
ls -al
cd ..
