require "json"
require "time"

json = File.open("data/old_listings.json")
listings = JSON.load(json)

new_listings = listings.map { |listing|
  t = Time.parse(listing["starting_at"])
  {
    "slug" => listing["slug"],
    "street_address" => listing["street_address"],
    "city" => listing["city"].strip,
    "state" => listing["state"],
    "zip" => listing["zip"],
    "location" => listing["location"],
    "number_photos" => listing["number_photos"],
    "date" => t.strftime("%Y-%m-%d"),
    "time" => t.strftime("%H:%M"),
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
}

File.open("data/listings.json", "wb") do |file|
  file.puts JSON.pretty_generate(new_listings)
end
