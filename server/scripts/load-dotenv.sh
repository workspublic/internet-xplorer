#!/usr/bin/env bash

# Usage:
# ./load-dotenv.sh ; $COMMAND

# adapted from
# https://stackoverflow.com/a/20909045/676001

load_dotenv () {
  if [ -n "$NODE_ENV" ]; then
    env_file=../../.env."$NODE_ENV"
  else
    env_file=../../.env
  fi

  unamestr=$(uname)
  if [ "$unamestr" = 'Linux' ]; then
    export $(grep -v '^#' $env_file | xargs -d '\n')
  elif [ "$unamestr" = 'FreeBSD' ] || [ "$unamestr" = 'Darwin' ]; then
    export $(grep -v '^#' $env_file | xargs -0)
  fi
}
