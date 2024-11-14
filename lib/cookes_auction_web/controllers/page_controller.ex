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

  def signed_up(conn, _params) do
    conn
    |> assign(:current_page, :signed_up)
    |> assign(:page_title, "Thank you for subscribing!")
    |> render(:signed_up)
  end

  def testimonials(conn, _params) do
    conn
    |> assign(:current_page, :testimonials)
    |> assign(:page_title, "Testimonials for Cooke's Auction Service")
    |> assign(:testimonials, CookesAuction.list_testimonials())
    |> render(:testimonials)
  end

  def search(conn, params) do
    sales =
      case params["q"] do
        nil -> []
        "" -> []
        q -> CookesAuction.search_sales(q)
      end

    conn
    |> assign(:current_page, :search)
    |> assign(:page_title, "Search")
    |> assign(:q, params["q"])
    |> assign(:sales, sales)
    |> render(:search)
  end
end
