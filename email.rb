require "net/http"
require_relative "listing"

class Email
  class << self
    def build_body(listingz)
      listings = listingz.map do |l|
        %Q|
          <li>
            <a href="http://cookesauction.com/sale/#{l.slug}">
              #{l.starting}
            </a> at #{l.full_address}
          </li>
        |
      end
      %Q|
        <p>Here are our upcoming sales:</p>
        <ul>#{listings.join("\n")}</ul>

        <p>See you at the next auction!</p>
        <p>Click to <a href="{unsubscribe}">unsubscribe</a></p>
      |
    end

    def send_emails(list)
      listings = Listing.upcoming

      if listings.count == 0
        return "Error: No upcoming sales"
      end

      msg_info = {
        "username" => ENV.fetch("ELASTIC_EMAIL_USERNAME"),
        "from" => "info@cookesauction.com",
        "from_name" => "Jesse Cooke",
        "api_key" => ENV.fetch("ELASTIC_EMAIL_API_KEY"),
        "subject" => "Upcoming Sales at Cooke's Auction Service",
        "body_html" => build_body(listings),
        "reply_to" => "info@cookesauction.com",
        "reply_to_name" => "Jesse Cooke",
        "lists" => list
      }
      begin
        uri = URI.parse("http://api.elasticemail.com/mailer/send")
        Net::HTTP.post_form(uri, msg_info).body
      rescue StandardError => e
        e.message
      end
    end
  end
end
