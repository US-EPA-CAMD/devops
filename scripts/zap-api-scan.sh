#!/bin/bash

cd $GITHUB_WORKSPACE

cp devops/api-zap-scan.conf devops/scripts/
cd devops/scripts/

# docker run -v $(pwd):/zap/wrk/:rw -t owasp/zap2docker-stable zap-api-scan.py -t https://easey-dev.app.cloud.gov/api/facility-mgmt/swagger -f openapi  -c api-zap-scan.conf -r report.html

docker run --name dv_git_workspace -v /zap/wrk gliderlabs/alpine:latest /bin/true

docker run -t --volumes-from dv_git_workspace -v /var/run/docker.sock:/var/run/docker.sock owasp/zap2docker-stable zap-api-scan.py -t https://easey-dev.app.cloud.gov/api/facility-mgmt/swagger -f openapi  -g zap.conf

echo "DEBUG: Files in Base directory"

docker volume ls

sudo ls -l /var/lib/docker/volumes/

# find / -name zap.conf -print > /dev/null 2>&3


# aws s3 ls s3://$ARTIFACTS_STORAGE/

# aws s3 cp report-$GITHUB_RUN_NUMBER.html s3://$ARTIFACTS_STORAGE/zap-scan-reports/
# aws s3 ls s3://$ARTIFACTS_STORAGE/zap-scan-reports/

