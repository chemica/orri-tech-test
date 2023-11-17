# README

## Project

Orri dev test

 - Github API integration
 - Constraint programming
 - Postgres SQL views

## Language versions

Ruby version: 3.2.2
Node version: 21.1.0

## Dependencies

Linux or OSX - This project may require some modification on Windows, 
and is not tested on OSX

just - a Make replacement for common command-line tasks. 

docker - container virtualisation for Rails and associated technologies

If you wish to run Rails locally, you will need Ruby and Node installed,
using the versions above. A Ruby version manager succh as ```nvm``` is
recommended.

## Database

A postgres database is provided as part of the docker-compose cloud. If 
you want to access Postgres from Rails running on the host machine, you
can update your /etc/hosts file to add db as an alias for 127.0.0.1:

```sudo sh -c "echo '127.0.0.1  db' >> /etc/hosts"```

## Dockerfiles

"Dockerfile" is used for development, while "Dockerfile.Production" is 
used for deployment to production. If you need to make any updates to
the development Dockerfile, please also update Dockerfile.Production.

## Ruby and Node versions

Rails in run in a container in order to match the production 
environment. If you need to update the Ruby or Node versions, please
update in both Dockerfiles, as well as the .ruby-version and 
.node-version files, then rebuild your containers and run your tests.

## Project setup

Set up your ```.env``` file. Copy ```.env.example``` in the root directory to ```.env```.
UpdateP variables in your ```.env``` file to match your personal settings. You will need:

- A Github personal access token

Initialise the project with:

```just setup```

Start the project with:

```just start``` (or ```just up``` if you want to see logs)

```just yarn build``` and ```just yarn build:css``` will build the front end files

Point your browser at:

```http://localhost:3000```

## Just commands

Type ```just``` to list the available commands. Most just commands will run in the relevant container. For example:

```just psql``` - open a psql session on the db container
```just shell``` - open a sh shell on the web container
```just bundle``` - bundle gems on the web container

Rails, rake and yarn commands are passed through to the container:

```just rails g migration CreateUser email:string name:string```