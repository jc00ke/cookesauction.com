require "json"
require "time"

json = File.open("data/old_listings.json")
listings = JSON.load(json)

new_listings = listings.map { |listing|
  t = Time.parse(listing["starting_at"])
  date = "#{t.year}-#{t.month}-#{t.day}"

  if [1, 2].include?(t.hour) && t.min == 45
    time = "9:45"
  else
    min = t.min.zero? ? "00" : t.min
    time = "#{t.hour}:#{min}"
  end
  {
    "slug" => listing["slug"],
    "starting_at" => "#{date} #{time}",
    "street_address" => listing["street_address"],
    "city" => listing["city"].strip,
    "state" => listing["state"],
    "zip" => listing["zip"],
    "location" => listing["location"],
    "number_photos" => listing["number_photos"].to_i,
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
  Time.parse(listing["starting_at"]).to_i * -1
}

File.open("data/listings.json", "wb") do |file|
  file.puts JSON.pretty_generate(new_listings)
end
