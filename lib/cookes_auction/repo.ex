defmodule CookesAuction.Repo do
  use Ecto.Repo,
    otp_app: :cookes_auction,
    adapter: Ecto.Adapters.SQLite3
end
