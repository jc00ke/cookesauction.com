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
    get "/contact-us", PageController, :contact_us
    get "/past-sales", PageController, :past_sales
    get "/privacy", PageController, :privacy
    get "/signup", PageController, :signup
    get "/signed-up", PageController, :signed_up
    get "/testimonials", PageController, :testimonials

    get "/sale/:slug", SaleController, :show
    get "/search", PageController, :search
  end

  # Other scopes may use custom stacks.
  # scope "/api", CookesAuctionWeb do
  #   pipe_through :api
  # end
end
