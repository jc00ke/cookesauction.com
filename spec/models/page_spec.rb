require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "Page Model" do
  it 'can be created' do
    @page = Page.new
    @page.should_not be_nil
  end
end
