#!/bin/sh

cd /app

export CRYPTOKNIGHT_BOT_NAME=$1
export CRYPTOKNIGHT_BOT_TOKEN=$2
export DOCKER_ENV=$3

MIX_ENV=prod mix server
