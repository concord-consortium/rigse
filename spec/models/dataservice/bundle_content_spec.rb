require 'spec_helper'

describe Dataservice::BundleContent do
  before(:each) do
    @valid_attributes = {
      :id => 1,
      :bundle_logger_id => 1,
      :position => 1,
      :body => "value for body",
      :created_at => Time.now,
      :updated_at => Time.now,
      :otml => "value for otml",
      :processed => false,
      :valid_xml => false,
      :empty => false,
      :uuid => "value for uuid"
    }
  end

  it "should create a new instance given valid attributes" do
    Dataservice::BundleContent.create!(@valid_attributes)
  end
end
