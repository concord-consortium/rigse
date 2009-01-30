require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/images/show.html.erb" do
  include ImagesHelper
  
  before(:each) do
    assigns[:image] = @image = stub_model(Image,
      :integer => ,
      :string => ,
      :string => ,
      :string => ,
      :integer => ,
      :integer => ,
      :integer => ,
      :string => 
    )
  end

  it "should render attributes in <p>" do
    render "/images/show.html.erb"
    response.should have_text(//)
    response.should have_text(//)
    response.should have_text(//)
    response.should have_text(//)
    response.should have_text(//)
    response.should have_text(//)
    response.should have_text(//)
    response.should have_text(//)
  end
end

