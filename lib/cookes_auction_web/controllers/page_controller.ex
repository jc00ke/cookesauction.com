defmodule CookesAuctionWeb.PageController do
  use CookesAuctionWeb, :controller

  def contact_us(conn, _params) do
    conn
    |> assign(:current_page, :contact_us)
    |> assign(:page_title, "Contact Cooke's")
    |> render(:contact_us)
  end

  def home(conn, _params) do
    conn
    |> assign(:current_page, :home)
    |> render(:home)
  end

  def past_sales(conn, _params) do
    conn
    |> assign(:current_page, :past_sales)
    |> assign(:page_title, "Past Sales")
    |> assign(:past_sales, CookesAuction.past_sales())
    |> render(:past_sales)
  end

  def privacy(conn, _params) do
    conn
    |> assign(:current_page, :privacy)
    |> assign(:page_title, "Privacy Policy")
    |> render(:privacy)
  end

  def signup(conn, _params) do
    conn
    |> assign(:current_page, :email_list)
    |> assign(:page_title, "Sign up for Cooke's email list")
    |> render(:signup)
  end

  def testimonials(conn, _params) do
    conn
    |> assign(:current_page, :testimonials)
    |> assign(:page_title, "Testimonials for Cooke's Auction Service")
    |> assign(:testimonials, CookesAuction.list_testimonials())
    |> render(:testimonials)
  end
end
