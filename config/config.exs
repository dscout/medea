import Config

config :logger, :default_formatter, format: {Medea.Formatter, :format}

if Mix.env() == :test, do: import_config("test.exs")
