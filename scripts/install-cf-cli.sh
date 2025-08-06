#!/bin/bash
set -eo pipefail

echo "--------------------------------------"
echo "--------- install-cf-cli.sh ----------"
echo "--------------------------------------"

curl -A "" -L "https://packages.cloudfoundry.org/stable?release=linux64-binary&source=github&version=v8" | tar -zx
sudo mv cf /usr/local/bin
sudo curl -o /usr/share/bash-completion/completions/cf https://raw.githubusercontent.com/cloudfoundry/cli-ci/master/ci/installers/completion/cf
cf version
