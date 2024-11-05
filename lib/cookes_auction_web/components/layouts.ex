defmodule CookesAuctionWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use CookesAuctionWeb, :controller` and
  `use CookesAuctionWeb, :live_view`.
  """
  use CookesAuctionWeb, :html

  embed_templates "layouts/*"

  attr :current_page, :atom, default: nil

  def navigation(assigns) do
    links = [
      {"Testimonials", :testimonials, ~p"/testimonials"},
      {"Past Sales", :past_sales, ~p"/"},
      {"Search", :search, ~p"/"},
      {"Email List", :email_list, ~p"/"},
      {"Contact", :past_sales, ~p"/"}
    ]

    assigns = assign(assigns, links: links)

    ~H"""
    <%= for {name, id, path} <- @links do %>
      <a
        class={"hover:text-amber-600 p-2 #{if @current_page == id, do: "text-white bg-green-600 hover:underline hover:text-white"}"}
        href={path}
      >
        <%= name %>
      </a>
    <% end %>
    """
  end
end
