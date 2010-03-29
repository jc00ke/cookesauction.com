require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "Email Model" do
  it 'can be created' do
    @email = Email.new
    @email.should_not be_nil
  end
end
