defmodule CookesAuctionWeb.Router do
  use CookesAuctionWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CookesAuctionWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CookesAuctionWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/testimonials", PageController, :testimonials
  end

  # Other scopes may use custom stacks.
  # scope "/api", CookesAuctionWeb do
  #   pipe_through :api
  # end
end
