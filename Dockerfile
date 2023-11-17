# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.2.2
ARG NODE_VERSION=21.1.0
ARG YARN_VERSION=1.22.19
ARG DEFAULT_PORT 3000
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

ARG UNAME=user
ARG USER_ID
ARG GROUP_ID

RUN addgroup --gid $GROUP_ID $UNAME
RUN adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID $UNAME

# Install packages needed to build gems and node modules
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential curl git libpq-dev libvips node-gyp pkg-config python-is-python3
RUN apt-get install -y npm

USER root

# Throw-away build stage to reduce size of final image
FROM base as build

# Rails app lives here
WORKDIR /rails

# Install JavaScript dependencies
ENV PATH=/usr/local/node/bin:$PATH

RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ 
RUN /tmp/node-build-master/bin/node-build --version "${NODE_VERSION}" /usr/local/node

# RUN mkdir /usr/local/lib/node_modules
# RUN chown -R user:user /usr/local/lib/node_modules

RUN npm install -g yarn@$YARN_VERSION
RUN rm -rf /tmp/node-build-master

# RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
#     /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
#     npm install -g yarn@$YARN_VERSION && \
#     rm -rf /tmp/node-build-master

ENV BUNDLE_PATH=/bundle/vendor
RUN gem install bundler

# Install application gems
COPY Gemfile* ./
RUN bundle install

RUN chown -R user:user /bundle/vendor/ruby

# Install node modules
COPY package.json* yarn.lock* ./
RUN yarn install

ADD . /rails

EXPOSE ${DEFAULT_PORT}
