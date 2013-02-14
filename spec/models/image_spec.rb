require File.expand_path('../../spec_helper', __FILE__)

describe Image do
  before(:each) do
    @dims = mock(
      :width  => 100,
      :height => 100)
    Paperclip::Geometry.stub!(:from_file).and_return(@dims)
    @valid_attributes = {
      'license_code' => mock(:code => 'CC-BY'),
      'name'         => 'testing',
      'user'         => mock_model(User),
      'image_file_name' => "testing"
    }
  end

  it "should create a new instance given valid attributes" do
    Image.create!(@valid_attributes)
  end
end
