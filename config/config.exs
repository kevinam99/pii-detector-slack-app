# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :pii_detector,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :pii_detector, PiiDetectorWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: PiiDetectorWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: PiiDetector.PubSub,
  live_view: [signing_salt: "BD5u/Uq4"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# slack app config
config :pii_detector, :slack,
  app_id: "A08M42LM8CR",
  client_id: "8709482003092.8718088722433",
  secret: "95818df4ebb93cae8085b5191cc94968",
  signing_secret: "d88373d8a1738e4a7cca43168bc9c6c2",
  verification_token: "Xxel3XUM6IceouEjkbKjG6mL"

config :slack, api_token: "xoxb-8709482003092-8694683744839-ooAxKuzuOlvkiJd5iJPHF5pg"
# cludflare config
config :pii_detector, :cloudflare,
  api_token: "2GM5GrK_Dpiz7GCELmP6x3tqgpUn03NyCDyt-B-6",
  account_id: "2532c238321714c590816151bbbb15e5"

# notion config

config :pii_detector, :notion,
  api_token: "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",
  database_id: "1234567890abcdef1234567890abcdef"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
