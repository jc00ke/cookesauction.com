defmodule CookesAuctionWeb.SaleController do
  use CookesAuctionWeb, :controller

  def show(conn, %{"slug" => slug} = params) do
    conn
    |> assign(:current_page, slug)
    |> assign(:q, params["q"])
    |> assign(:sale, CookesAuction.get_sale_by_slug!(slug))
    |> render(:show)
  end
end
