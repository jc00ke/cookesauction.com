require "listing"
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
Listing.visible.each do |listing|
  proxy "/sale/#{listing.slug}", "/listing.html", :locals => { :listing => listing }, :ignore => true
end

###
# Helpers
###
activate :directory_indexes

activate :pagination do
  pageable_resource :listings do |page|
    page.path == "/past-sales"
  end

  pageable_set :listings do
    Listing.previous
  end
end

activate :s3_sync do |s3|
  s3.bucket = "cookesauction.com"
  s3.region = "us-west-2"
  s3.aws_access_key_id = ENV["AWS_ACCESS_KEY_ID"]
  s3.aws_secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]
  s3.delete = false
end

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Reload the browser automatically whenever files change
# configure :development do
#   activate :livereload
# end

# Methods defined in the helpers block are available in templates
helpers do
  def upcoming_listings
    Listing.upcoming
  end

  def pagez(pagination)
    p = 1.upto(pagination.page_num).to_a.reverse.take(5).reverse
    n = pagination.page_num.upto([pagination.page_num + 5, pagination.total_page_num].min).to_a.reverse.take(5).reverse
    temp = p + n
    [temp.uniq, pagination.page_num]
  end

  def active(page)
    "active" if "#{page}.html" == current_resource.path
  end

  def map_pic_src(listing, size="300x270")
    address = escaped_address(listing)
    params = map_params(listing, size)
    "https://maps.google.com/maps/api/staticmap?#{address}&#{params}&#{google_static_maps_param}"
  end

  def google_static_maps_param
    "key=#{ENV["GOOGLE_MAPS_STATIC_KEY"]}"
  end

  def escaped_address(listing)
    if location = listing.location
      loc = location.all?(&:present?) ? location.join(',') : listing.full_address
      loc.gsub(/, /, ',').gsub(/ /, "+") if loc
    end
  end

  def map_directions_link(listing)
    address = escaped_address(listing)
    "https://maps.google.com/maps?f=d&source=s_d&hl=en&mra=ls&ie=UTF8&z=15&daddr=#{address}"
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
    "/sale/#{listing.slug}"
  end

  def image_url(listing_slug, idx, size=nil)
    "https://s3.amazonaws.com/cookes-auction-service/images/sales/#{listing_slug}/#{idx}#{size}.jpg"
  end

  def listing_has_photos?(listing)
    listing.has_photos?
  end

  def is_home_page?
    page.path == "/index.html"
  end
end

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

set :url_root, 'https://cookesauction.com'

activate  :search_engine_sitemap,
          process_url: -> (url) { url.chomp('/') },
          exclude_if: -> (resource) { resource.path =~ /past-sales\/pages/ }

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

  activate :robots, :rules => [
    {:user_agent => '*', :allow => %w(/)}
  ],
  :sitemap => "#{url_root}/sitemap.xml"
end
