import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/pii_detector start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :pii_detector, PiiDetectorWeb.Endpoint, server: true
end

if config_env() == :prod do
  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :pii_detector, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :pii_detector, PiiDetectorWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/bandit/Bandit.html#t:options/0
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  # slack app config
  config :pii_detector, :slack,
    app_id: "A08M42LM8CR",
    client_id: "8709482003092.8718088722433",
    secret: System.fetch_env!("SLACK_CLIENT_SECRET"),
    signing_secret: System.fetch_env!("SLACK_SIGNING_SECRET"),
    verification_token: System.fetch_env!("SLACK_VERIFICATION_TOKEN"),
    user_auth_token: System.fetch_env!("SLACK_USER_AUTH_TOKEN")

  config :slack, api_token: System.fetch_env!("SLACK_API_TOKEN")
  # cludflare config
  config :pii_detector, :cloudflare,
    api_token: System.fetch_env!("CLOUDFLARE_API_TOKEN"),
    account_id: System.fetch_env!("CLOUDFLARE_ACCOUNT_ID")

  # notion config
  config :pii_detector, :notion, api_token: System.fetch_env!("NOTION_API_TOKEN")

  config :pii_detector, :huggingface_api_key, System.fetch_env!("HUGGINGFACE_API_KEY")

  config :pii_detector, google_ai_api_key: System.fetch_env!("GOOGLE_AI_API_KEY")
  config :pii_detector, google_ai_model: System.get_env("GOOGLE_AI_MODEL") || "gemini-2.0-flash"

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :pii_detector, PiiDetectorWeb.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your config/prod.exs,
  # ensuring no data is ever sent via http, always redirecting to https:
  #
  #     config :pii_detector, PiiDetectorWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.
end
