defmodule CookesAuction.EmailTest do
  use ExUnit.Case, async: true

  alias CookesAuction.Email
  alias CookesAuction.Sales.Sale

  test "send_emails/1 without sales" do
    assert {:error, _} = Email.send_emails([])
  end

  test "send_emails/1 with sales" do
    sale = %Sale{slug: "an-slug", starting_at: ~N[2029-12-25 09:30:00]}

    Req.Test.stub(Email, fn conn ->
      {:ok, body, conn} = Plug.Conn.read_body(conn)
      assert body =~ "username=an-username"
      assert body =~ "from=info%40cookesauction.com"
      assert body =~ "from_name=Jesse+Cooke"
      assert body =~ "api_key=an-api_key"
      assert body =~ "subject=Upcoming+Sales+at+Cooke%27s+Auction+Service"
      assert body =~ "body_html"
      assert body =~ URI.encode_www_form("https://cookesauction.com/sale/#{sale.slug}")
      assert body =~ "reply_to=info%40cookesauction.com"
      assert body =~ "reply_to_name=Jesse+Cooke"
      assert body =~ "lists=an-list"
      Req.Test.text(conn, "success")
    end)

    {:ok, resp} =
      Email.send_emails([sale],
        username: "an-username",
        api_key: "an-api_key",
        list: "an-list"
      )

    assert resp.body == "success"
  end

  test "body/1 renders the body" do
    sale = %Sale{slug: "an-slug", starting_at: ~N[2029-12-25 09:30:00]}
    body = Email.body([sale])
    assert body =~ sale.slug
    assert body =~ CookesAuction.full_address(sale)
    assert body =~ CookesAuction.formatted_starting_at(sale)
    assert body =~ "{unsubscribe}"
  end
end
