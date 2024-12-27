defmodule Mix.Tasks.Email do
  @moduledoc """
  Loads upcoming sales and sends them off to Elastic Email.

  Takes a single argument, which is the name of the list.
  """
  @shortdoc "Sends upcoming sales to subscribers."

  use Mix.Task

  @requirements ["app.start"]

  @impl Mix.Task
  def run(argv) do
    {opts, _args, _invalid} = OptionParser.parse(argv, strict: [prod: :boolean, test: :boolean])
    list = if opts[:prod], do: "Auction Listings Subscribers", else: "test"

    sales =
      if opts[:test],
        do: CookesAuction.past_sales() |> Enum.take(1),
        else: CookesAuction.upcoming_sales()

    shell = Mix.shell()

    case CookesAuction.Email.send_emails(sales, list: list) do
      {:ok, resp} -> shell.info(resp.body)
      {:error, msg} when is_binary(msg) -> shell.error(msg)
      {:error, resp} -> IO.inspect(resp) |> shell.error()
    end
  end
end
