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
