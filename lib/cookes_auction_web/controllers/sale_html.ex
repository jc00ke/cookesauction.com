defmodule CookesAuctionWeb.SaleHTML do
  @moduledoc """
  This module contains pages rendered by SaleController.

  See the `sale_html` directory for all templates available.
  """
  use CookesAuctionWeb, :html

  embed_templates "sale_html/*"

  def content(sale, q) when q in [nil, ""] do
    raw(Earmark.as_html!(sale.content))
  end

  def content(sale, q) do
    Earmark.as_html!(sale.content)
    |> String.replace(q, "<mark>#{q}</mark>")
    |> raw()
  end
end
