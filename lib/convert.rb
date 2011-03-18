require "./reverse_markdown.rb"
require "sequel"

DB = Sequel.connect("sqlite://old.db")

@r = ReverseMarkdown.new

def t(header, text)
  "### #{header}\n#{text}" if text
end

def h(text)
  t = text.gsub(%r{<br.*>}, "\n").
           gsub("&amp;", "and").
           gsub("&", "and").
           gsub(%r{<style.*/style>}, "").
           gsub(%r{\u001D}, '"').
           gsub(%r{\u0013}, '').
           gsub(%r{\u0019}, "'")
  @r.parse_string(t)
end

DB[:sale].each do |s|
  previous_id = s[:PriKey].to_i
  puts "*" * 80
  puts previous_id
  visible = s[:Visible] == 1
  starting_at = "#{s[:SaleDate]} #{s[:StartTime]}"
  street_address, city, state, zip = s[:LocatedAt].split(',')

  sale_title = s[:SpecialTitle]

  real_estate = s[:RealEstate]
  sale_type = (real_estate) ? :real_estate : :public_auction

  directions = s[:Directions]
  antique_furniture = s[:AFurniture]
  contemporary_furniture = s[:CFurniture]
  collectibles_and_glassware = s[:CandG]
  tools_lawn_and_garden = s[:TLandG]
  appliances_and_electronics = s[:AandE]

  vehicles = s[:Vehicles]
  client = s[:EstateOf]
  note = s[:Note]
  terms_of_sale = s[:SaleTerms]
  terms_of_real_estate = s[:RealEstateTerms]

  ## h4 # p # ul # li
  other = h(s[:Other]) if s[:Other]
  miscellaneous = h(s[:Misc]) if s[:Misc]

  content = [
    t("Directions", directions),
    t("Antique Furniture", antique_furniture),
    t("Contemporary Furniture", contemporary_furniture),
    t("Collectibles and Glassware", collectibles_and_glassware),
    t("Tools, Lawn and Garden", tools_lawn_and_garden),
    t("Appliances and Electronics", appliances_and_electronics),
    t("Vehicles", vehicles),
    t("Note", note),
    t("Terms of Sale", terms_of_sale),
    t("Terms of Real Estate", terms_of_real_estate)
  ].join("\n\n")

  l = Listing.new
  l.build_page
  l.previous_id = previous_id
  l.page.visible = visible
  l.starting_at = starting_at
  l.street_address = street_address
  l.city = city
  l.state = state || "IN"
  l.zip = zip
  l.location = [street_address, city] if [79, 91].include?(previous_id)
  l.sale_title = sale_title || "Auction at #{s[:LocatedAt]}"
  l.page.title = l.sale_title = sale_title || "Auction at #{s[:LocatedAt]}"
  l.sale_type = sale_type
  l.page.content = content
  l.page.description = "Cooke's Auction Service #{sale_type.to_s.sub('_', ' ')} at #{s[:LocatedAt]} on #{l.starting}"
  if l.save
    puts "imported #{previous_id}"
  else
    puts l.errors.inspect
    puts l.page.errors.inspect
  end


end
