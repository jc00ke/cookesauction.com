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
    today = NaiveDateTime.utc_now() |> NaiveDateTime.beginning_of_day()

    from(s in Sale, order_by: [desc: s.id], where: s.starting_at < ^today)
    |> Repo.all()
  end

  @doc """
  Returns the list of upcoming sales.

  ## Examples

    iex> upcoming_sales()
    [%Sale{}]
  """
  def upcoming_sales do
    today = NaiveDateTime.utc_now() |> NaiveDateTime.beginning_of_day()

    from(s in Sale, order_by: [desc: s.id], where: s.starting_at >= ^today)
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

  def directions_url(sale) do
    address_query =
      address_query(sale)
      |> URI.encode_query()

    "https://maps.google.com/maps?f=d&source=s_d&hl=en&mra=ls&ie=UTF8&z=15"
    |> URI.parse()
    |> URI.append_query(address_query)
    |> URI.to_string()
  end

  def full_address(%Sale{} = sale) do
    "#{sale.street_address}, #{sale.city}, #{sale.state} #{sale.zip}"
  end

  defp address_query(%Sale{location: nil} = sale) do
    %{"daddr" => full_address(sale)}
  end

  defp address_query(%Sale{location: location} = sale) when is_list(location) do
    %{"daddr" => Enum.join(sale.location, ",")}
  end

  def show_photos?(%Sale{hide_photos: false, number_photos: n}) when n > 0, do: true
  def show_photos?(%Sale{}), do: false

  def formatted_starting_at(%Sale{starting_at: starting_at}) do
    Calendar.strftime(starting_at, "%B %d %Y %I:%M %p")
  end

  @doc """
    iex> search_sales("Ford")
    [%Sale{}, ...]

    with
      results as (
        select
          id,
          rank
        from
          sales_fts
        where
          sales_fts match ?
      )
    select
      sales.*
    from
      sales
      join results on sales.id = results.id
    order by
      results.rank ASC;
  """
  def search_sales(query) do
    fts_query =
      from(f in "sales_fts",
        where: fragment("sales_fts match ?", ^query),
        select: %{
          id: f.id,
          rank: f.rank
        }
      )

    sales_query =
      from(s in Sale,
        join: f in subquery(fts_query),
        on: s.id == f.id,
        order_by: [asc: f.rank],
        select: s
      )

    Repo.all(sales_query)
  end
end
