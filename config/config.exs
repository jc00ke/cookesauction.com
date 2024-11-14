# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :cookes_auction,
  ecto_repos: [CookesAuction.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configure your database
config :cookes_auction, CookesAuction.Repo,
  database: Path.expand("../cookes_auction.db", __DIR__),
  pool_size: 5,
  read_only: true,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

# Configures the endpoint
config :cookes_auction, CookesAuctionWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: CookesAuctionWeb.ErrorHTML, json: CookesAuctionWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: CookesAuction.PubSub,
  live_view: [signing_salt: "0cuelxpH"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  cookes_auction: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  cookes_auction: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
