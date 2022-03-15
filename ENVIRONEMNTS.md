### Specifying Environments

Create React App does not allow to change the value of the NODE_ENV environment variable. The npm start command will set the NODE_ENV to development, the npm test command will set the NODE_ENV to test, and the npm run build command sets the NODE_ENV to production.

Given that the NODE_ENV is set for you and that the value for NODE_ENV is used to reconcile the correct .env file, the following .env files can be used:

- .env
- .env.local (loaded for all environments except test)
- .env.development, .env.test, .env.production
- .env.development.local, .env.test.local, .env.production.local

### Order of priority/inheritance

The order of priority and inheritance is exactly the same as that described for the parcel bundler:

- .env.${NODE_ENV}.local
- .env.${NODE_ENV}
- .env.local
- .env

### Additional environments

To use environment variables for environments other than development, test, and production, you can create additional .env files and load the correct .env file using env-cmd.

To take a staging environment as an example:

- Create a .env.staging file and add environment variables to the file
- Add env-cmd as a project dependency (npm install env-cmd --save)
- Create script commands for the staging environment
- Run the start:staging or build:staging command to start a local staging environment or
  to build the staging environment bundle

It's important to note that the NODE_ENV will still be set to development when running the npm start command and the NODE_ENV will be set to production when running the npm run build command, so environment variables can still be loaded from either .env.development or .env.production depending on the command used.

For example, running the start:staging command from above would load environment variables from the following files (in order of priority):

- .env.staging
- .env.development.local
- .env.development
- .env.local
- .env

[JavaScript environment variables reference](https://www.robertcooper.me/front-end-javascript-environment-variables)
