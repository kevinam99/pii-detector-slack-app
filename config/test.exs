import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :pii_detector, PiiDetectorWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "h/5txfi5oOK/cpKQdHigVbf65eWCoZIhw6IRui+Kg6LlFqxdysRSvDaTaBxqxxW1",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :pii_detector, notion_module: PiiDetector.NotionMock
config :pii_detector, slack_module: PiiDetector.SlackMock
config :pii_detector, cloudflare_module: PiiDetector.CloudlareMock
