#!/bin/bash

docker run -v $(pwd):/zap/wrk/:rw -t owasp/zap2docker-stable zap-api-scan.py -t https://easey-dev.app.cloud.gov/api/facility-mgmt/swagger -f openapi
