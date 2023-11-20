# README

## Orri dev test

 - Github API integration
 - Constraint programming
 - Postgres SQL views

Constraint programming is implemented here using the csp-solver library.

### Task 1: Integration with Public API
Objective: Initiate a GitHub API search for a specific user, storing pertinent information such as stars, repositories, and their most-used languages (measured in bytes, refer to GitHub API documentation).

#### Expected Outcome:
Successfully query GitHub API for user details.
Store user information, including stars, repositories, and language usage.

#### Implementation
The ```octokit``` gem is used as an idiomatic Ruby library for accessing Github. As this process steps outside the scope of what would comfortably fit in a model or controller, The class ```GithubImport``` in the ```app/services``` folder handles the import task.

### Task 2: Background Job - Periodic Data Refresh
Objective: Extend GitHub API integration using constraint programming for efficient querying and storing of user repository details. Implement a background job for periodic data refresh, optimizing the schedule based on the specified ranking system. Prioritize users by star count, repository count, predominant use of Ruby, and ideally, Python. Penalize users with GoLang or TypeScript in repositories. Ensure users appear once a day and avoid back-to-back scheduling for those with star counts within +/- 2.

#### Expected Outcome:
Background job implemented using constraint programming.
Schedule optimized based on ranking criteria.
Users refreshed periodically with prioritization according to the outlined constraints.

#### Implementation
```sidekiq``` us used for handling background jobs, along with ```sidekiq-cron``` to allow a regular job schedule. In this case, import jobs are set to run at the rate of 1 per hour.
Ranking is carried out within the user model. A trivial weighting process provides a numeric value per user. Weighting values have been chosed essentially at random, but can be easily tweaked for optimisation at a later stage.
With an hourly schedule we can think of each day as a series of 24 slots. Constraint programming is used to fill those slots with users, according to the specified requirements.
Constraint programming is handled here using the ```csp-solver``` gem. This gem implements constraint programming using hard constraints, which means that certain combinations of constraints and users will fail to solve. Unfortunately, Ruby constraint programming libraries and information on soft constraints both appear to be thin on the ground. As implementing a Ruby soft constraint programming kit would be out of scope for a tech test, I am using a series of increasingly lenient attempts to arrive at a solution. As a caveat, this is hardly ideal, and would exponentially increase in complexity as requirements were added.
Nevertheless, this approach requires a few assumptions:

 - We always want to arrive at a solution, even if it's not ideal.
 - The importance of the rules, from most to least important, are: "Ensure users appear once a day", "Prioritize users by ranking", and "Avoid back-to-back scheduling for those with star counts within +/- 2".
 - The first rule is the only hard constraint.
 - If we have more than 24 users in the database, we will only schedule the most recently added 24. (Otherwise, we will always fail at rule 1.)

I will call a collection of constraints a "strategy". We can then attempt a number of strategies in order, ranking from "strict" (with a higher chance of failing to solve) to "lenient" (with a 100% chance of success), using fewer constraints, or constraints with less strict comparisons.
Ensuring users appear once a day is a fairly trivial constraint, and appears in all strategies. As we only allow 24 or fewer users, this constraint will always be able to solve.
Prioritising by rank can be carried out by ensuring that high ranking users appear more often than low ranking users. This can be made strict (by comparing pairs of users with ```<``` or ```>``` operators) or less strict (by using ```<=``` or ```>=``` operators). The former will fail after the number of users passes a threshold (6 in this case, or in a more general case, x*(x+1)/2 > y where y is the number of slots and x is the number of users). The latter will always be able to solve, as a result containing one of each user is a valid result.
Avoiding back-to-back scheduling of users with similar star counts is carried out using constraints on pairs of result slots. As I'm currently unable to conceive of a way to soften this constraint mathematically, it can be eliminated from less strict strategies.

The job of scheduling is carried out by the ```Scheduler``` class in ```app/services/scheduler.rb```. This class sets up the parameters and the solver, then attempts strategies until a solution is found. The ```import_slots``` table is then updated to reflect the new schedule, and the hourly import job pulls the user from there each hour.  

### Task 3: PostgreSQL Views
Objective: Create a PostgreSQL view offering a simplified summary of a user's repositories and stars. Prioritize efficiency and clarity in the design.

#### Expected Outcome:
PostgreSQL view developed for a concise summary of user repositories and stars.
Design reflects both efficiency and clarity in presentation.

### Implementation
The ```scenic``` gem is used to implement Postgres materialized views. The user_details Postgres view caches some information, and is recalculated each time a new user is imported. The "UserDetail" readonly model represents the view, and the index page displays user details from that view.

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