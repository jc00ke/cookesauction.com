defmodule CookesAuctionWeb.PageController do
  use CookesAuctionWeb, :controller

  def home(conn, _params) do
    conn
    |> assign(:current_page, :home)
    |> render(:home)
  end

  def privacy(conn, _params) do
    conn
    |> assign(:current_page, :privacy)
    |> assign(:page_title, "Privacy Policy")
    |> render(:privacy)
  end

  def signup(conn, _params) do
    conn
    |> assign(:current_page, :signup)
    |> assign(:page_title, "Sign up for Cooke's email list")
    |> render(:signup)
  end

  def testimonials(conn, _params) do
    testimonials = CookesAuction.list_testimonials()

    conn
    |> assign(:current_page, :testimonials)
    |> assign(:page_title, "Testimonials for Cooke's Auction Service")
    |> assign(:testimonials, testimonials)
    |> render(:testimonials)
  end
end
