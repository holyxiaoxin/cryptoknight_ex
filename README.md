# telegram crypto_knight

## Create a telegram bot:
1. search for BotFather in telegram app.
1. `/newbot`
1. Add [environment variables](https://www.cyberciti.biz/faq/set-environment-variable-linux/):
  1. development: `CRYPTOKNIGHT_DEV_BOT_NAME`, `CRYPTOKNIGHT_DEV_BOT_TOKEN`
  1. production: `CRYPTOKNIGHT_BOT_NAME`, `CRYPTOKNIGHT_BOT_TOKEN`

### To develop

```
mix
```


### To release

```
MIX_ENV=prod mix deps.get
MIX_ENV=prod mix deps.compile
MIX_ENV=prod mix compile
MIX_ENV=prod elixir --detached --sname cryptoknight -S mix
```

## DOCKER

Add .env file at project root, so that docker-compose have access to these environment variables
```
CRYPTOKNIGHT_DEV_BOT_NAME=xxx
CRYPTOKNIGHT_DEV_BOT_TOKEN=xxx
CRYPTOKNIGHT_BOT_NAME=xxx
CRYPTOKNIGHT_BOT_TOKEN=xxx
```

### To develop
docker-compose -f docker/docker-compose.dev.yml up

### To release
docker-compose -f docker/docker-compose.prod.yml up -d
