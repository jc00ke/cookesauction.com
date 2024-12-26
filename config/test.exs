import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :cookes_auction, CookesAuction.Repo,
  database: Path.expand("../cookes_auction_test.db", __DIR__),
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :cookes_auction, CookesAuctionWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "C+SUVeEzn/BeOhFclMb9AvnWXi/CAKM+rB/jV/glhEY93jnZI+pXn8BcRjBHN5Ou",
  server: false

config :cookes_auction,
  elastic_email_req_options: [
    plug: {Req.Test, CookesAuction.Email}
  ]

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
