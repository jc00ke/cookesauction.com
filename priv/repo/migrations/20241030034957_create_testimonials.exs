defmodule CookesAuction.Repo.Migrations.CreateTestimonials do
  use Ecto.Migration

  def change do
    create table(:testimonials) do
      add :author, :string, default: "Anonymous"
      add :content, :string, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
