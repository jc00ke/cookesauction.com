defmodule CookesAuction do
  @moduledoc """
  CookesAuction keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  import Ecto.Query

  alias CookesAuction.Content.Testimonial
  alias CookesAuction.Sales.Sale
  alias CookesAuction.Repo

  @doc """
  Returns the list of sales.

  ## Examples

    iex> list_sales()
    [%Sale{}]
  """
  def list_sales do
    Repo.all(Sale)
  end

  @doc """
  Returns the list of past sales.

  ## Examples

    iex> past_sales()
    [%Sale{}]
  """
  def past_sales do
    today = NaiveDateTime.utc_now()

    from(s in Sale, order_by: [desc: s.id], where: s.starting_at < ^today)
    |> Repo.all()
  end

  @doc """
  Returns a sale by slug.

  ## Examples

    iex> get_sale_by_slug!("some-slug")
    %Sale{}

    iex> get_sale_by_slug!("doesn't exist")
    ** Ecto.NoResultsError{}
  """
  def get_sale_by_slug!(slug) do
    from(s in Sale, where: s.slug == ^slug)
    |> Repo.one!()
  end

  @doc """
  Returns the list of testimonials.

  ## Examples

    iex> list_testimonials()
    [%Testimonial{}]
  """
  def list_testimonials do
    Repo.all(Testimonial)
  end
end
