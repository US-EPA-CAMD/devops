## Getting Started
These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites
- [Cloud.gov Setup & Configuration](https://cloud.gov/docs/getting-started/setup/)
- [Configure Environment Variables](#Environment Variables)
- [Establish Cloud.gov SSH Tunnel](#Cloud.gov SSH tunnel)

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
```
$ cf target -o epa-easey -s dev
```
3. Open SSH tunnel
```
$ cf ssh auth-api -L <LOCAL_PORT>:<DB_HOST>:5432
```
4. Keep the SSH tunnel open while running the application
> NOTE: For more information on Cloud.gov, please refer to their [documentation](https://cloud.gov/docs/).


## Building, Testing, & Running the application
From within the projects root directory run the following commands using the yarn command line interface

**Run in development mode**
```
$ yarn start:dev
```

**Install/update package dependencies & run in development mode**
```
$ yarn up
```

**Unit tests**
```
$ yarn test
```

**Build**
```
$ yarn build
```

**Run in production mode**
```
$ yarn start
```

## Built With
[ReactJS](https://reactjs.org) a free open-source front-end JavaScript library and web development framework for building user interfaces based on UI components

[NestJS](https://nestjs.com) a free open-source framework for building efficient and scalable Node.js server-side applications using Typescript and combines elements of OOP (Object Oriented Programming), FP (Functional Programming), and FRP (Functional Reactive Programming) 

[Cloud.gov](https://cloud.gov) a FedRAMP authorized Cloud Platform as a Service (PaaS) built on AWS for US Government agencies
