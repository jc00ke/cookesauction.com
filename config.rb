###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (https://middlemanapp.com/advanced/dynamic_pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###
activate :directory_indexes

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
# configure :development do
#   activate :livereload
# end

# Methods defined in the helpers block are available in templates
helpers do
#   def some_helper
#     "Helping"
#   end

  def active(page)
    "active" if "#{page}.html" == current_resource.path
  end

  def map_pic_src(listing, size="300x270")
    address = escaped_address(listing)
    params = map_params(listing, size)
    "//maps.google.com/maps/api/staticmap?#{address}&#{params}"
  end

  def escaped_address(listing)
    if location = listing["location"]
      location.all?(&:present?) ? location.join(',') : full_address(listing)
    end.gsub(/, /, ',').gsub(/ /, "+")
  end

  def full_address(listing)
    "#{listing["street_address"]}, #{listing["city"]}, #{listing["state"]} #{listing["zip"]}"
  end

  def map_params(listing, size)
    address = escaped_address(listing)
    {
      :center => address,
      :size => size,
      :markers => "color:blue|label:A|#{address}",
      :sensor => false
    }.inject([]){ |m,s|
      m << "#{s.first}=#{s.last}"
    }.join('&')
  end

  def listing_link_href(listing)
    "/sale/#{listing["slug"]}"
  end

  def image_url(listing_slug, idx, size=nil)
    "http://ds8xlcugsewg4.cloudfront.net/images/sales/#{listing_slug}/#{idx}#{size}.jpg"
  end

  def listing_has_photos?(listing)
    listing["number_photos"].to_i > 0
  end

  def starting(listing)
    t = Time.parse(listing["starting_at"])
    t.strftime("%A, %d %b %Y %l:%M %p")
  end

  def nice_type(listing)
    listing["type"].split('_').each { |t| t.capitalize! }.join(' ')
  end
end

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end
