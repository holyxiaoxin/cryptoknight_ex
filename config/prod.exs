use Mix.Config

config :app,
  bot_name: System.get_env("CRYPTOKNIGHT_BOT_NAME")

config :nadia,
  token: System.get_env("CRYPTOKNIGHT_BOT_TOKEN")
