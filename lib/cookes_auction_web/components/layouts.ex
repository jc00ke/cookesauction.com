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
      {"Home", :home, ~p"/"},
      {"Testimonials", :testimonials, ~p"/testimonials"},
      {"Past Sales", :past_sales, ~p"/past-sales"},
      {"Search", :search, ~p"/search"},
      {"Email List", :email_list, ~p"/signup"},
      {"Contact", :contact_us, ~p"/contact-us"}
    ]

    assigns = assign(assigns, links: links)

    ~H"""
    <nav>
      <ul>
        <li :for={{name, id, path} <- @links}>
          <.link href={path} class={if @current_page != id, do: "secondary"}>
            <%= name %>
          </.link>
        </li>
      </ul>
    </nav>
    """
  end
end
