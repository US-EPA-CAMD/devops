# Devops
This repo stores common shared devops related files used by one or more repos within the US-EPA_CAMD organization

## Cloud Foundry CLI
For the scripts to function properly the [Cloud Foundry cli] must be installed in order to run cf commands

## Environment Variables
On Linux or Debian systems create a bash script in the /etc/profile.d folder with the following environment variables...
```sh
export CF_USERNAME=set to cf service account id
export CF_PASSWORD=set to cf service account password
```
NOTE: On Windows systems just create system level environment variables

## Cloud Foundry Login
```sh
$ cf api https://api.fr.cloud.gov
$ cf auth
$ cf target -o $CF_ORG_NAME -s $CF_SPACE_NAME
```

## CF SSH Tunnel
This script will login to cloud.gov and establish an SSH tunnel forwarding the remote port back to the local port providing a channel to communicate to cloud.gov services such as a database service. The application specified must be bound to the service prior to establishing the connection.
```sh
$ ./cf-ssh-tunnel.sh --organization $CF_ORG_NAME --space $CF_SPACE_NAME --host $CF_DB_HOST --application $CF_APPLICATON --localPort $LOCAL_PORT --remotePort $REMOTE_PORT
```
NOTE: Replace $PARAMS with actual values or see the Environment Variables section regarding creating environment variables

#### EXAMPLE
```sh
$ ./cf-ssh-tunnel.sh --organization epa-easey --space dev --host cg-aws-broker-prodg1t1yiwikl6s1rs.ci7nkegdizyy.us-gov-west-1.rds.amazonaws.com --application facilities-api --localPort 15210 --remotePort 5432
```

## Bind Service
To bind an application to a service within cloud.gov run the following commands at a cmd prompt that is logged into cloud.gov...

#### Usage
```sh
$ cf bind-service APP_NAME SERVICE_INSTANCE [-c PARAMETERS_AS_JSON] [--binding-name BINDING_NAME]
```
Optionally provide service-specific configuration parameters in a valid JSON object in-line:
```sh
$ cf bind-service APP_NAME SERVICE_INSTANCE -c '{"name":"value","name":"value"}'
```
Optionally provide a file containing service-specific configuration parameters in a valid JSON object. The path to the parameters file can be an absolute or relative path to a file.
```sh
$ cf bind-service APP_NAME SERVICE_INSTANCE -c PATH_TO_FILE
```
Example of valid JSON object: { "permissions": "read-only" } Optionally provide a binding name for the association between an app and a service instance:
```sh
$ cf bind-service APP_NAME SERVICE_INSTANCE --binding-name BINDING_NAME
```

#### EXAMPLES
Linux/Mac:
```sh
$ cf bind-service myapp mydb -c '{"permissions":"read-only"}'
```
Windows Command Line:
```sh
$ cf bind-service myapp mydb -c "{\"permissions\":\"read-only\"}"
```
Windows PowerShell:
```sh
$ cf bind-service myapp mydb -c '{\"permissions\":\"read-only\"}'`
$ cf bind-service myapp mydb -c ~/workspace/tmp/instance_config.json --binding-name BINDING_NAME
```

## Github Runner Error
The runner is trying to run your file as a script, but it looks like your file is missing the execute bit.

Example Error:
/home/runner/work/_temp/62e75df7-5b8e-4d5b-b728-cbac6fff4ad1.sh: line 1: devops/scripts/*.sh: Permission denied
Error: Process completed with exit code 126.

On Linux or macOS, run:
```sh
$ chmod +x scripts/
$ git add .
```
On Windows, run:
```sh
$ git add --chmod=+x -- scripts/*
$ git add --chmod=+x -- scripts/*.*
```
And then push the changes back up.

License
----
MIT

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. See http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)

[Cloud Foundry cli]: <https://docs.cloudfoundry.org/cf-cli/install-go-cli.html>
