#!/usr/bin/env bash

set -euo pipefail

# Usage:
# ./load-dotenv.sh ; $COMMAND

# adapted from
# https://stackoverflow.com/a/20909045/676001

load_dotenv () {
  if [ -z ${NODE_ENV+x} ]; then
    env_file=../../.env
  else
    env_file=../../.env."$NODE_ENV"
  fi

  unamestr=$(uname)
  if [ "$unamestr" = 'Linux' ]; then
    export $(grep -v '^#' $env_file | xargs -d '\n')
  elif [ "$unamestr" = 'FreeBSD' ] || [ "$unamestr" = 'Darwin' ]; then
    export $(grep -v '^#' $env_file | xargs -0)
  fi
}
