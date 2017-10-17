require "oga"
require "set"

class Contractor
  attr_reader :name, :email, :fax, :cname

  def initialize(name, email, fax)
    @name = name
    @email = email
    @fax = fax
    @cname = clean_name(name)
  end

  def self.from_text(node_text)
    text = node_text.tr("\n", "").gsub(%r{\s+}, " ")
    name = text.match(/\A(.*)ADDRESS/)[1].strip
    email = text.scan(/COMPANY EMAIL: ([^\s]+)/).join("")
    fax = text.scan(/COMPANY FAX: (\d{3})-(\d{3})-(\d{4})/).join("")
    new(name, email, fax)
  end

  def eql?(other)
    self.cname == other.cname
  end

  def hash
    @cname.hash
  end

  def clean_name(name)
    name.downcase.strip.tr(" ", "")
  end

  def has_enough_info?
    @fax.size > 0 && @email.size > 0
  end
end

handle = File.open("fac.html")

doc = Oga.parse_html(handle)

contractors = Set.new

doc.css("table").each do |table|
  node_text = table.css("td")[1].text
  contractor = Contractor.from_text(node_text)
  contractors << contractor if contractor.has_enough_info?
end

contractors.each do |c|
  puts [c.fax, c.email, c.name].inspect
end
