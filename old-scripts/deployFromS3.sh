#!/bin/bash

cd $GITHUB_WORKSPACE

echo "DEBUG TAG value -> $3"
environment=$(echo $3|cut -d'.' -f1)
echo "Environment: $environment"

if [[ -z $environment ]]; then
    echo "Unable to read the environment from the TAG"
    echo "Will deploy the latest version specified in deployments.properties"
    export environment="latest"
fi


validEnvironments=("dev" "test" "stage" "latest" "rollback-stage" "rollback-test" "rollback-dev")

if [[ !  " ${validEnvironments[@]} " =~ " ${environment} " ]]; then
    echo "${environment} - Not a valid environment value"
    exit
fi


echo "Retrieving keys ..."
cf api  https://api.fr.cloud.gov
cf auth $1 $2
cf target -o "epa-prototyping" -s "dev-easey-in"

# S3_CREDENTIALS=`cf service-key "${SERVICE_INSTANCE_NAME}" "${KEY_NAME}" | tail -n +2`
S3_CREDENTIALS=`cf service-key "deployment-artifacts" "deployment-artifacts-svc-key" | tail -n +2`
export AWS_ACCESS_KEY_ID=`echo "${S3_CREDENTIALS}" | jq -r .access_key_id`
export AWS_SECRET_ACCESS_KEY=`echo "${S3_CREDENTIALS}" | jq -r .secret_access_key`
export BUCKET_NAME=`echo "${S3_CREDENTIALS}" | jq -r .bucket`
export AWS_DEFAULT_REGION=`echo "${S3_CREDENTIALS}" | jq -r '.region'`

export appname=$(grep ^$environment.appname deployment.properties|cut -d'=' -f2)
export version=$(grep ^$environment.version deployment.properties|cut -d'=' -f2)
export build=$(grep ^$environment.build deployment.properties|cut -d'=' -f2)

if [[ -z $appname || -z $version || -z $build ]]; then
    echo "Please assign values to $environment.appname, $environment.version, $environment.build in deployment.properties"
    echo "Exiting deployment"
    exit 0
fi

mkdir deployments
aws s3 cp  s3://cg-2f1f8ec0-a961-4d0b-af39-2ed9f109078e/$appname.$version.$build.zip deployments/
cd deployments
unzip -q $appname.$version.$build.zip
ls -l 
cd $appname/starter-kit
cf push

