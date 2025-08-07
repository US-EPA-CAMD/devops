#!/bin/bash
set -eo pipefail

echo "--------------------------------------"
echo "--------- install-cf-cli.sh ----------"
echo "--------------------------------------"

curl -A "" -L "https://packages.cloudfoundry.org/stable?release=linux64-binary&source=github&version=v8" | tar -zx
sudo mv cf8 /usr/local/bin
sudo ln -sf /usr/local/bin/cf8 /usr/local/bin/cf
sudo curl -o /usr/share/bash-completion/completions/cf https://raw.githubusercontent.com/cloudfoundry/cli-ci/master/ci/installers/completion/cf
cf version