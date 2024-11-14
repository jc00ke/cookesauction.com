defmodule CookesAuctionWeb.SaleController do
  use CookesAuctionWeb, :controller

  def show(conn, %{"slug" => slug}) do
    conn
    |> assign(:current_page, slug)
    |> assign(:sale, CookesAuction.get_sale_by_slug!(slug))
    |> render(:show)
  end
end
