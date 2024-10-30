defmodule CookesAuction.Repo.Migrations.AddTestimonialsTable do
  use Ecto.Migration

  def change do
    create table(:testimonials) do
      add :author, :string, default: "Anonymous"
      add :content, :string, null: false

      timestamps()
    end
  end
end
