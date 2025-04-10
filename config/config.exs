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
  secret: "",
  signing_secret: "",
  verification_token: ""

config :slack, api_token: ""
# cludflare config
config :pii_detector, :cloudflare,
  api_token: "",
  account_id: "2532c238321714c590816151bbbb15e5"

# notion config
config :pii_detector, :notion, api_token: ""

config :pii_detector, notion_module: PiiDetector.Notion
config :pii_detector, slack_module: PiiDetector.Slack
config :pii_detector, cloudflare_module: PiiDetector.Cloudlare

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
