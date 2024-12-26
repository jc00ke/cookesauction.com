defmodule CookesAuction.Email do
  use CookesAuctionWeb, :html

  def send_emails(sales, opts \\ [])
  def send_emails([], _opts), do: {:error, "No sales to send"}

  def send_emails(sales, opts) do
    list = Keyword.get(opts, :list, "test")

    params = %{
      "username" => username(opts),
      "from" => "info@cookesauction.com",
      "from_name" => "Jesse Cooke",
      "api_key" => api_key(opts),
      "subject" => "Upcoming Sales at Cooke's Auction Service",
      "body_html" => body(sales),
      "reply_to" => "info@cookesauction.com",
      "reply_to_name" => "Jesse Cooke",
      "lists" => list
    }

    [
      url: "https://api.elasticemail.com/mailer/send",
      form: params
    ]
    |> Keyword.merge(Application.get_env(:cookes_auction, :elastic_email_req_options, []))
    |> Req.post()
  end

  defp api_key(opts) do
    Keyword.get_lazy(
      opts,
      :api_key,
      fn ->
        Application.get_env(:cookes_auction, __MODULE__)[:elastic_email_api_key]
      end
    )
  end

  defp username(opts) do
    Keyword.get_lazy(
      opts,
      :username,
      fn ->
        Application.get_env(:cookes_auction, __MODULE__)[:elastic_email_username]
      end
    )
  end

  def body(sales) do
    assigns = %{sales: sales, uri: URI.new!("https://cookesauction.com")}

    ~H"""
    <p>Here are our upcoming sales:</p>
    <ul :for={sale <- @sales}>
      <li>
        <.link href={url(@uri, ~p"/sale/#{sale.slug}")}>
          <%= CookesAuction.formatted_starting_at(sale) %> at <%= CookesAuction.full_address(sale) %>
        </.link>
      </li>
    </ul>

    <p>See you at the next auction!</p>
    <p>Click to <a href="{unsubscribe}">unsubscribe</a></p>
    """
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
  end
end
