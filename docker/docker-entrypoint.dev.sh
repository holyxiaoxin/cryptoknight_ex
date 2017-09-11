#!/bin/sh

cd /app

export CRYPTOKNIGHT_DEV_BOT_NAME=$1
export CRYPTOKNIGHT_DEV_BOT_TOKEN=$2
export DOCKER_ENV=$3

mix server
