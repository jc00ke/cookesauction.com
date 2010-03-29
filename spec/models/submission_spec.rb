require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "Submission Model" do
  it 'can be created' do
    @submission = Submission.new
    @submission.should_not be_nil
  end
end
