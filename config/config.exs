import Config

config :logger, :default_formatter, format: {Medea.Formatter, :format}
