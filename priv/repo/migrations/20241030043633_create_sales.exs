defmodule CookesAuction.Repo.Migrations.CreateSales do
  use Ecto.Migration

  def change do
    create table(:sales) do
      add :slug, :string
      add :street_address, :string
      add :city, :string
      add :state, :string
      add :zip, :string
      add :location, {:array, :decimal}
      add :number_photos, :integer
      add :starting_at, :naive_datetime
      add :type, :string
      add :title, :string
      add :content, :text
      add :visible, :boolean, default: true, null: false
      add :hide_photos, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create(unique_index(:sales, [:slug]))
  end
end
