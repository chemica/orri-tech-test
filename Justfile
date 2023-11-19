set positional-arguments := true
# Define variables
DATABASE_NAME       := "orri_development"
DOCKER_COMPOSE_FILE := "docker-compose.yml"

# List all just tasks
default:
  @just --list

# Build Docker containers
build:
  @docker-compose build web --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g)   
  @docker-compose build jobs --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g)   

# Build Docker containers without cache
rebuild:
  @docker-compose build web --no-cache --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) 
  @docker-compose build jobs --no-cache --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) 

# Set up the rails project for the first time
setup:
  just build
  just start
  just db-setup
  just test-db-setup
  just migrate
  just test-migrate

# Start Docker containers
start:
  @docker-compose -f {{DOCKER_COMPOSE_FILE}} up -d

# Start Docker containers in the foreground
up:
  @docker-compose -f {{DOCKER_COMPOSE_FILE}} up

# Stop Docker containers
stop:
  @docker-compose -f {{DOCKER_COMPOSE_FILE}} down

# Stop Docker containers
down:
  @docker-compose -f {{DOCKER_COMPOSE_FILE}} down

# Restart Docker containers
restart:
  @docker-compose -f {{DOCKER_COMPOSE_FILE}} restart

# Set up the database
db-setup:
  @docker-compose -f {{DOCKER_COMPOSE_FILE}} exec web bin/rails db:setup || true

# Set up the test database
test-db-setup:
  @docker-compose -f {{DOCKER_COMPOSE_FILE}} exec web bin/rails db:setup RAILS_ENV=test || true

# Run database migrations
migrate:
  @docker-compose -f {{DOCKER_COMPOSE_FILE}} exec web bin/rails db:migrate

# Run database migrations
test-migrate:
  @docker-compose -f {{DOCKER_COMPOSE_FILE}} exec web bin/rails db:migrate RAILS_ENV=test

# Bundle install gems
bundle:
  @docker-compose -f {{DOCKER_COMPOSE_FILE}} exec web bundle install

# Rollback database migrations
rollback:
  @docker-compose -f {{DOCKER_COMPOSE_FILE}} exec web bin/rails db:rollback

# Seed the database
seed:
  @docker-compose -f {{DOCKER_COMPOSE_FILE}} exec web bin/rails db:seed

# Open a Rails console
console:
  @docker-compose -f {{DOCKER_COMPOSE_FILE}} exec web bin/rails console

# Run tests
test:
  @docker-compose -f {{DOCKER_COMPOSE_FILE}} exec web bundle exec rspec

# Run tests
rspec:
  @docker-compose -f {{DOCKER_COMPOSE_FILE}} exec web bundle exec rspec

# Run a shell in the web container
shell:
  @docker-compose -f {{DOCKER_COMPOSE_FILE}} exec web sh

# Run a shell in the web container
run-shell:
  @docker-compose -f {{DOCKER_COMPOSE_FILE}} run web sh

# Remove all Docker containers and volumes
clean:
  @docker-compose -f {{DOCKER_COMPOSE_FILE}} down -v

# Connect to the Postgres database using psql
psql:
  @docker-compose -f {{DOCKER_COMPOSE_FILE}} exec db psql -U postgres -d {{DATABASE_NAME}}

# Run a rake task in the web container
@rake *args='':
  `echo "docker-compose -f {{DOCKER_COMPOSE_FILE}} exec web bundle exec rake $@"`

# Run a rails task in the web container
@rails *args='':
  `echo "docker-compose -f {{DOCKER_COMPOSE_FILE}} exec web bin/rails $@"`

# Run a yarn command in the web container
@yarn *args='':
  `echo "docker-compose -f {{DOCKER_COMPOSE_FILE}} exec web bundle exec yarn $@"`



