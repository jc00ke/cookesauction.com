defmodule CookesAuction.Sales.Sale do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sales" do
    field :type, Ecto.Enum, values: [:public_auction, :real_estate]
    field :visible, :boolean, default: false
    field :state, :string
    field :zip, :string
    field :title, :string
    field :location, {:array, :decimal}
    field :slug, :string
    field :street_address, :string
    field :city, :string
    field :number_photos, :integer
    field :starting_at, :naive_datetime
    field :content, :string
    field :hide_photos, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(sale, attrs) do
    sale
    |> cast(attrs, [:slug, :street_address, :city, :state, :zip, :location, :number_photos, :starting_at, :type, :title, :content, :visible, :hide_photos])
    |> validate_required([:slug, :street_address, :city, :state, :zip, :location, :number_photos, :starting_at, :type, :title, :content, :visible, :hide_photos])
  end
end
