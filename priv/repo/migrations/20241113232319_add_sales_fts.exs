defmodule CookesAuction.Repo.Migrations.AddSalesFts do
  use Ecto.Migration

  def up do
    execute "CREATE VIRTUAL TABLE IF NOT EXISTS sales_fts USING fts5(id, content)"
  end

  def down do
    execute "DROP VIRTUAL TABLE IF EXISTS sales_fts"
  end
end
