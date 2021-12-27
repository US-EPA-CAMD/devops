## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

- Set environment variables
- Establish cloud.gov SSH tunnel

**Environment Variables**

You will need to set up the following environment variables in order to access the database. These are to be used for development purposes only.

- EASEY_DB_HOST: localhost
- EASEY_DB_PORT: `LOCAL_PORT` used in the SSH tunnel

Please reach out to an EPA tech lead (see Mike Heese or Jason Whitehead) to get the values for these variables

- EASEY_DB_NAME
- EASEY_DB_PWD
- EASEY_DB_USER
 

**Cloud.gov SSH tunnel**

1. [Log in and set up the command line](https://cloud.gov/docs/getting-started/setup/#set-up-the-command-line) 

2. Target the development org (you will need to be granted permission to access this):
```bash
$ cf target -o epa-easey -s dev
```
3. Open SSH tunnel
```bash
$ cf ssh auth-api -L <LOCAL_PORT>:<DB_HOST>:5432
```
4. Keep the SSH tunnel open while running the application

> NOTE: For more information on cloud.gov, please refer to their [documentation](https://cloud.gov/docs/).

### Installing
1. Open your terminal and navigate to the directory you wish to store this repository.

2. Clone this repository

    ```shell
    # If using SSH
    $ git clone git@github.com:US-EPA-CAMD/REPOSITORY_NAME.git
    
    # If using HTTPS
    $ git clone https://github.com/US-EPA-CAMD/REPOSITORY_NAME.git
    ```

3. Navigate to the root project directory

    ```
    $ cd REPOSITORY_NAME
    ```

4. Install dependencies 
    
    ```
    $ yarn install
    ```
### Run the appication 

From within the project directory, you can run:

```bash
# Runs the api in the development mode
$ yarn start:dev
```

The page will reload if you make edits via the use of nodemon.<br />
You will also see any lint errors in the console.

```bash
# for production mode
$ yarn start
```

### Run the tests

```bash
# unit tests
$ yarn test

# e2e tests
$ yarn test:e2e

# test coverage
$ yarn test:cov
```

## Built With
​
[NestJS](https://nestjs.com/) - server-side Node.js framework

[Cloud.gov](https://cloud.gov/) - Platform as a Service (PaaS)
