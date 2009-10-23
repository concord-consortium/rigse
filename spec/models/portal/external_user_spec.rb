require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Portal::ExternalUser do
  before(:each) do
    @valid_attributes = {
      :external_user_domain_id => 1,
      :user_id => 1,
      :external_user_key => "value for external_user_key",
      :uuid => "value for uuid"
    }
  end

  it "should create a new instance given valid attributes" do
    Portal::ExternalUser.create!(@valid_attributes)
  end
end
