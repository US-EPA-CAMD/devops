#!/bin/bash

cd $GITHUB_WORKSPACE

cp devops/api-zap-scan.conf devops/scripts/
cd devops/scripts/

# docker run -v $(pwd):/zap/wrk/:rw -t owasp/zap2docker-stable zap-api-scan.py -t https://easey-dev.app.cloud.gov/api/facility-mgmt/swagger -f openapi  -c api-zap-scan.conf -r report.html

docker run -t owasp/zap2docker-stable zap-api-scan.py -t https://easey-dev.app.cloud.gov/api/facility-mgmt/swagger -f openapi  -g zap.conf

echo "DEBUG: Files in Base directory"

pwd
ls -ltr

ls -ltr zap.conf


aws s3 ls s3://$ARTIFACTS_STORAGE/

# aws s3 cp report-$GITHUB_RUN_NUMBER.html s3://$ARTIFACTS_STORAGE/zap-scan-reports/
# aws s3 ls s3://$ARTIFACTS_STORAGE/zap-scan-reports/

