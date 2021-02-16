#!/bin/bash

cp devops/api-zap-scan.conf . 
docker run -v $(pwd):/zap/wrk/:rw -t owasp/zap2docker-stable zap-api-scan.py -t https://easey-dev.app.cloud.gov/api/facility-mgmt/swagger -f openapi -j -c api-zap-scan.conf -r report-$GITHUB_RUN_NUMBER.html

echo "DEBUG: Files in Base directory"

ls -ltr

echo "DEBUG: Files in Devops  directory"

ls -ltr devops/

echo "DEBUG: Files in Devops/scripts  directory"

ls -ltr devops/scripts/

echo "DEBUG: AWS S3 listing"

aws s3 ls s3://$ARTIFACTS_STORAGE/

# aws s3 cp report-$GITHUB_RUN_NUMBER.html s3://$ARTIFACTS_STORAGE/zap-scan-reports/
# aws s3 ls s3://$ARTIFACTS_STORAGE/zap-scan-reports/

