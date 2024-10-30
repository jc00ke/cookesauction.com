defmodule CookesAuction.Content.Testimonial do
  use Ecto.Schema
  import Ecto.Changeset

  schema "testimonials" do
    field :author, :string
    field :content, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(testimonial, attrs) do
    testimonial
    |> cast(attrs, [:author, :content])
    |> validate_required([:author, :content])
  end
end
