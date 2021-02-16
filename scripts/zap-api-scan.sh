#!/bin/bash

cd $GITHUB_WORKSPACE

# cp devops/api-zap-scan.conf devops/scripts/
# cd devops/scripts/

# docker run -v $(pwd):/zap/wrk/:rw -t owasp/zap2docker-stable zap-api-scan.py -t https://easey-dev.app.cloud.gov/api/facility-mgmt/swagger -f openapi  -c api-zap-scan.conf -r report.html

# sudo mkdir /zap/wrk
# sudo chmod 777 /zap/wrk

# sudo docker run --name dv_git_workspace -v /zap/wrk gliderlabs/alpine:latest /bin/true

# sudo docker run -t --volumes-from dv_git_workspace owasp/zap2docker-stable zap-api-scan.py -t https://easey-dev.app.cloud.gov/api/facility-mgmt/swagger -f openapi -d  -g zap.conf

echo "DEBUG: Files in Base directory"

# docker volume ls

# volumeName=$(docker volume ls --format "{{.Name}}")


# sudo ls -lR /var/lib/docker/volumes/$volumeName

# sudo find /var/lib/docker/volumes/$volumeName/ -name zap.conf -print

sudo find $GITHUB_WORKSPACE  -name zap-api-scan.conf -print 


# aws s3 ls s3://$ARTIFACTS_STORAGE/

# aws s3 cp report-$GITHUB_RUN_NUMBER.html s3://$ARTIFACTS_STORAGE/zap-scan-reports/
# aws s3 ls s3://$ARTIFACTS_STORAGE/zap-scan-reports/

