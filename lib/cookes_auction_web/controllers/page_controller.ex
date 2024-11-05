defmodule CookesAuctionWeb.PageController do
  use CookesAuctionWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home)
  end

  def testimonials(conn, _params) do
    testimonials = CookesAuction.list_testimonials()

    conn
    |> assign(:page_title, "Testimonials for Cooke's Auction Service")
    |> assign(:testimonials, testimonials)
    |> render(:testimonials)
  end
end
