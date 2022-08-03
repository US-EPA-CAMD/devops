#!/bin/bash

echo "--------------------------------------"
echo "-- environment-variables-noTags.sh ---"
echo "--------------------------------------"

echo "Initialing & Configuring environment..."
echo "Environment: $ENV"

name=$(grep -w name manifest-vars.yml | cut -d':' -f2 | xargs)
echo "APP_NAME=$name" >> $GITHUB_ENV
echo "ENV_VAR_PREFIX=$ENV_VAR_PREFIX" >> $GITHUB_ENV
export AWS_DEFAULT_REGION='us-gov-west-1'
echo "AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION" >> $GITHUB_ENV
echo "CF_API_URL=https://api.fr.cloud.gov" >> $GITHUB_ENV
echo "CF_ORG_NAME=epa-easey" >> $GITHUB_ENV
artifacts_storage='cg-85627a9c-7d48-446a-8cb7-5daa5c694169'
echo "ARTIFACTS_STORAGE=$artifacts_storage" >> $GITHUB_ENV

# version=$(grep sonar.projectVersion sonar-project.properties | cut -d'=' -f2)
# version=$version.$GITHUB_RUN_NUMBER
if [[ $PACKAGE == "latest" ]]; then
  PACKAGE=$(aws s3api list-objects --bucket $artifacts_storage --prefix $name --output text --query 'Contents[].{Key: Key}' | tail -n1)
  PACKAGE="${PACKAGE%.*}"
fi
echo "PACKAGE=$PACKAGE" >> $GITHUB_ENV
echo "Package: $PACKAGE"
echo ""

case $ENV in
  # (CDC)
  #   echo "CF_ORG_SPACE=cdc" >> $GITHUB_ENV
  #   echo "CF_ORG_SPACE=cdc"
  #   ;;
  (Beta)
    echo "CF_ORG_SPACE=beta" >> $GITHUB_ENV
    echo "CF_ORG_SPACE=beta"

    echo "URL=$URL+beta/" >> $GITHUB_ENV

    echo "CF_ENV_DEPLOYMENT_SVC=$CF_BETA_DEPLOYMENT_SVC" >> $GITHUB_ENV
    echo "CF_ENV_DEPLOYMENT_SVC_PWD=$CF_BETA_DEPLOYMENT_SVC_PWD" >> $GITHUB_ENV
    ;;
  (Test)
    echo "CF_ORG_SPACE=test" >> $GITHUB_ENV
    echo "CF_ORG_SPACE=test"

    echo "URL=$URL+test/" >> $GITHUB_ENV

    echo "CF_ENV_DEPLOYMENT_SVC=$CF_TST_DEPLOYMENT_SVC" >> $GITHUB_ENV
    echo "CF_ENV_DEPLOYMENT_SVC_PWD=$CF_TST_DEPLOYMENT_SVC_PWD" >> $GITHUB_ENV
    ;;
  (Staging)
    echo "CF_ORG_SPACE=staging" >> $GITHUB_ENV
    echo "CF_ORG_SPACE=staging"

    echo "URL=$URL+staging/" >> $GITHUB_ENV

    echo "CF_ENV_DEPLOYMENT_SVC=$CF_STG_DEPLOYMENT_SVC" >> $GITHUB_ENV
    echo "CF_ENV_DEPLOYMENT_SVC_PWD=$CF_STG_DEPLOYMENT_SVC_PWD" >> $GITHUB_ENV
    ;;
  (Performance)
    echo "CF_ORG_SPACE=perf" >> $GITHUB_ENV
    echo "CF_ORG_SPACE=perf"

    echo "URL=$URL+performance/" >> $GITHUB_ENV

    echo "CF_ENV_DEPLOYMENT_SVC=$CF_PERF_DEPLOYMENT_SVC" >> $GITHUB_ENV
    echo "CF_ENV_DEPLOYMENT_SVC_PWD=$CF_PERF_DEPLOYMENT_SVC_PWD" >> $GITHUB_ENV
    ;;    
  # This is to match case of no tag for dev env as we do not want a malformed tag pushing to dev
  "")
    echo "CF_ORG_SPACE=dev" >> $GITHUB_ENV
    echo "CF_ORG_SPACE=dev"

    echo "URL=$URL+dev/" >> $GITHUB_ENV

    echo "CF_ENV_DEPLOYMENT_SVC=$CF_DEV_DEPLOYMENT_SVC" >> $GITHUB_ENV
    echo "CF_ENV_DEPLOYMENT_SVC_PWD=$CF_DEV_DEPLOYMENT_SVC_PWD" >> $GITHUB_ENV
    ;;
  # if nothing matches we need to error and exit since the CF_ORG_SPACE is not properly set
  *)
    echo "ERROR: Unknown environment, cannot  properly set the CF_ORG_SPACE env var!"
    exit 1
    ;;
esac

api=true

case $GUTHUB_REPOSITORY in
  (US-EPA-CAMD/easey-campd-ui)
    echo "URL=$URL+repo/" >> $GITHUB_ENV
    api=false
    ;;
  (US-EPA-CAMD/easey-ecmps-ui)
    echo "URL=$URL+repo/" >> $GITHUB_ENV
    api=false
    ;;
  (US-EPA-CAMD/easey-account-api)
    echo "URL=$URL+account-mgmt/" >> $GITHUB_ENV
    ;;
  (US-EPA-CAMD/easey-auth-api)
    echo "URL=$URL+auth-mgmt/" >> $GITHUB_ENV
    ;;
  (US-EPA-CAMD/easey-camd-services)
    echo "URL=$URL+camd-services/" >> $GITHUB_ENV
    ;;
  (US-EPA-CAMD/easey-emissions-api)
    echo "URL=$URL+emissions-mgmt/" >> $GITHUB_ENV
    ;;
  (US-EPA-CAMD/easey-facilities-api)
    echo "URL=$URL+facilities-mgmt/" >> $GITHUB_ENV
    ;;
  (US-EPA-CAMD/easey-mdm-api)
    echo "URL=$URL+master-data-mgmt/" >> $GITHUB_ENV
    ;;
  (US-EPA-CAMD/easey-monitor-plan-api)
    echo "URL=$URL+monitor-plan-mgmt/" >> $GITHUB_ENV
    ;;
  (US-EPA-CAMD/easey-qa-certifications-api)
    echo "URL=$URL+qa-certifications-mgmt/" >> $GITHUB_ENV
    ;;
  *)
    echo "repo not set!! please edit environment-variables-deploy.sh"
    ;;
esac

if api; then
  echo "URL=$URL+swagger/" >> $GITHUB_ENV
  echo "URL=$URL+swagger/"
fi