defmodule CookesAuctionWeb.PageController do
  use CookesAuctionWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def testimonials(conn, _params) do
    testimonials = CookesAuction.list_testimonials()

    conn
    |> assign(:testimonials, testimonials)
    |> render(:testimonials, layout: false)
  end
end
