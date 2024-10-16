defmodule CookesAuction do
  @moduledoc """
  CookesAuction keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @listings_path "priv/listings.yml"
  @external_resource @listings_path

  @content CookesAuction.Listing.load_from_yaml(@listings_path)

  def list_listings, do: Map.values(@content)

  def get_listing!(slug), do: Map.fetch!(@content, slug)
end
