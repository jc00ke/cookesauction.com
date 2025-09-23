defmodule Mix.Tasks.Cookes.Fts do
  @moduledoc """
  Inserts sale content into the full-text search index.
  """
  @shortdoc "Inserts sale content into FTS"

  use Mix.Task

  @requirements ["app.start"]
  @impl Mix.Task
  def run(argv) do
    {[sale: sale_id], _args, _invalid} = OptionParser.parse(argv, strict: [sale: :integer])
    sale = CookesAuction.get_sale!(sale_id)

    Ecto.Adapters.SQL.query!(
      CookesAuction.Repo,
      "INSERT INTO sales_fts(id, content, sales_fts, rank) VALUES($1, $2, NULL, NULL)",
      [sale_id, sale.content]
    )
  end
end
