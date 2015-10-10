require "json"

json = File.open("data/old_listings.json")
listings = JSON.load(json)

new_listings = listings.map { |listing|
  {
    "slug" => listing["slug"],
    "street_address" => listing["street_address"],
    "city" => listing["city"].strip,
    "state" => listing["state"],
    "zip" => listing["zip"],
    "location" => listing["location"],
    "number_photos" => listing["number_photos"].to_i,
    "starting_at" => listing["starting_at"],
    "type" => listing["sale_type"],
    "title" => listing["sale_title"],
    # derive page
    # * title
    # * description
    # * keywords?
    "content" => listing["page"]["content"],
    "visible" => listing["page"]["visible"],
    "result" => listing["result"],
    "update_text" => listing["updated_text"],
  }
}.sort_by { |listing|
  listing["starting_at"]
}.reverse

File.open("data/listings.json", "wb") do |file|
  file.puts JSON.pretty_generate(new_listings)
end
