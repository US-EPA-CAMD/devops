#!/bin/bash

cd $GITHUB_WORKSPACE
DATE=$(date +"%m-%d-%Y.%H:%M:%S")
zip $1-zapscan-$GITHUB_RUN_NUMBER-$DATE.zip report_html.html report_json.json report_md.md

aws s3 cp $1-zapscan-$GITHUB_RUN_NUMBER-$DATE.zip s3://$ARTIFACTS_STORAGE/zap-scan-reports/
aws s3 ls s3://$ARTIFACTS_STORAGE/zap-scan-reports/
