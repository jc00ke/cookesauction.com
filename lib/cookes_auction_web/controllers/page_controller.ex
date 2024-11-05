defmodule CookesAuctionWeb.PageController do
  use CookesAuctionWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def privacy(conn, _params) do
    conn
    |> assign(:page_title, "Privacy Policy")
    |> render(:privacy)
  end

  def testimonials(conn, _params) do
    testimonials = CookesAuction.list_testimonials()

    conn
    |> assign(:page_title, "Testimonials for Cooke's Auction Service")
    |> assign(:testimonials, testimonials)
    |> render(:testimonials)
  end
end
