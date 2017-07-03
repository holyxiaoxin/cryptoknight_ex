use Mix.Config

config :app,
  bot_name: System.get_env("CRYPTOKNIGHT_DEV_BOT_NAME")

config :nadia,
  token: System.get_env("CRYPTOKNIGHT_DEV_BOT_TOKEN")
