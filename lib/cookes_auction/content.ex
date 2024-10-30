defmodule CookesAuction.Content do
  alias CookesAuction.Content.Testimonial
  alias CookesAuction.Repo

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
