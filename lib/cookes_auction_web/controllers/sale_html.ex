defmodule CookesAuctionWeb.SaleHTML do
  @moduledoc """
  This module contains pages rendered by SaleController.

  See the `sale_html` directory for all templates available.
  """
  use CookesAuctionWeb, :html

  embed_templates "sale_html/*"
end
