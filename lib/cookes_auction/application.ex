defmodule CookesAuction.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CookesAuctionWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:cookes_auction, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CookesAuction.PubSub},
      # Start a worker by calling: CookesAuction.Worker.start_link(arg)
      # {CookesAuction.Worker, arg},
      # Start to serve requests, typically the last entry
      CookesAuctionWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CookesAuction.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CookesAuctionWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
