use Mix.Config

import_config "#{Mix.env}.exs"

config :logger, format: "[$level] $message\n",
  backends: [{LoggerFileBackend, :commands}, {LoggerFileBackend, :info}, {LoggerFileBackend, :error}]

config :logger, :error,
  path: "log/error.log",
  level: :error

config :logger, :info,
  path: "log/info.log",
  level: :info

config :logger, :commands,
  path: "log/commands.log",
  level: :debug,
  metadata_filter: [commands: 1]
