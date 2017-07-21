#!/bin/sh

cd /app

. ./docker/dev.env
. ./docker/setup_env.sh

mix deps.compile
mix compile
mix server
