use Mix.Config

config :app,
  bot_name: "cryptoknight"

config :nadia,
  token: System.get_env("CRYPTOKNIGHT_BOT_TOKEN")

import_config "#{Mix.env}.exs"
