defmodule CookesAuctionWeb.SitemapController do
  use CookesAuctionWeb, :controller

  def index(conn, _params) do
    conn
    |> put_resp_content_type("text/xml")
    |> render("index.xml", layout: false, sales: CookesAuction.list_sales())
  end
end
