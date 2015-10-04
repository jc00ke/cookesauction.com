class Email
  include Mongoid::Document
  include Mongoid::Timestamps

  validates_uniqueness_of :email
  validates_presence_of :email
  validates_presence_of :name
  validates_format_of :email, :with => /.*@.*/

  field :name
  field :email

  class << self
    def queue
      listingz = Listing.upcoming
      return if listingz.count == 0
      body = Email.build_body(listingz)
      all.each do |e|
        SALE_EMAIL_QUEUE.push(:to => e.email, :body => body, :id => e.id.to_s)
      end
    end

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
        <p>Here are our upcoming sales:.</p>
        <ul>#{listings.join("\n")}</ul>

        <p>Hope to see you at the next auction!</p>
        <p>Click to automatically <a href="http://cookesauction.com/unsubscribe/##email_id##">unsubscribe</a></p>
      |
    end

    def send_listings(msg)
      params = {  :to => msg[:to],
                  :from => "Cooke's Auction <info@cookesauction.com>",
                  :reply_to => 'info@cookesauction.com',
                  :subject => "Upcoming Sales at Cooke's Auction Service",
                  :html_body => msg[:body].sub('##email_id##', msg[:id]),
                  :via => :smtp,
                  :via_options => Email.smtp}
      if ENV['RACK_ENV'] == 'production'
        Pony.mail params
      else
        require 'pp'
        pp params
      end
    end

    def smtp
      { :address => "smtp.sendgrid.net",
        :port     => 587,
        :authentication   => :plain,
        :user_name        => ENV['SENDGRID_USERNAME'],
        :password         => ENV['SENDGRID_PASSWORD'],
      }
    end
  end
end

SALE_EMAIL_QUEUE = GirlFriday::WorkQueue.new(:sale_email, :size => 2) do |msg|
  Email.send_listings(msg)
end
