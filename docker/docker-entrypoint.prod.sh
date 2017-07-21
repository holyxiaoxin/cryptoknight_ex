#!/bin/sh

cd /app

. ./docker/prod.env
. ./docker/setup_env.sh

MIX_ENV=prod mix deps.compile
MIX_ENV=prod mix compile
MIX_ENV=prod mix server
