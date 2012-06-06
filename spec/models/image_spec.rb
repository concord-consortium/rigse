require File.expand_path('../../spec_helper', __FILE__)
SAMPLE_IMAGE = "#{RAILS_ROOT}/public/images/cc-footer.png" unless defined?(SAMPLE_IMAGE)

describe Image do
  before(:each) do
    user = Factory(:user)
    @valid_attributes = {
      :name => "Image Test",
      :attribution => "Some subtitle",
      :image => File.open(SAMPLE_IMAGE),
      :user => user
    }
  end

  it "should create a new instance given valid attributes" do
    Image.create!(@valid_attributes)
  end

  it "should create static images in the filesystem" do
    i = Image.create!(@valid_attributes)
    %w{original attributed thumb}.each do |type|
      File.exists?("#{RAILS_ROOT}/public/system/images/#{i.id}/#{type}/cc-footer.png").should be_true
    end
  end
end
