require 'spec_helper'

describe Page do
  before(:each) do
    @valid_attributes = {
      :name => "first page",
      :description => "a description of the first page",
      :position => 1,
      :teacher_only => false
    }
  end

  it "should create a new instance given valid attributes" do
    Page.create!(@valid_attributes)
  end
end
