defmodule CookesAuction.Listing do
  defstruct [
    :city,
    :content,
    :custom_card_photo,
    :hide_photos,
    :inline_image_list,
    :location,
    :number_photos,
    :result,
    :slug,
    :starting_at,
    :state,
    :street_address,
    :title,
    :type,
    :update_text,
    :visible,
    :zip
  ]

  def load_from_yaml(path) do
    YamlElixir.read_from_file!(path)
    |> Enum.map(&from_map/1)
  end

  def from_map(map) do
    atom_map = Map.new(map, fn {key, value} -> {String.to_existing_atom(key), value} end)

    struct!(__MODULE__, %{
      atom_map
      | content: Earmark.as_html!(atom_map.content),
        starting_at: NaiveDateTime.from_iso8601!(atom_map.starting_at)
    })
    |> Map.put(:hide_photos, Map.get(atom_map, :hide_photos, false))
  end
end
