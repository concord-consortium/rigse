require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/images/edit.html.erb" do
  include ImagesHelper
  
  before(:each) do
    assigns[:image] = @image = stub_model(Image,
      :new_record? => false,
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

  it "should render edit form" do
    render "/images/edit.html.erb"
    
    response.should have_tag("form[action=#{image_path(@image)}][method=post]") do
      with_tag('input#image_integer[name=?]', "image[integer]")
      with_tag('input#image_string[name=?]', "image[string]")
      with_tag('input#image_string[name=?]', "image[string]")
      with_tag('input#image_string[name=?]', "image[string]")
      with_tag('input#image_integer[name=?]', "image[integer]")
      with_tag('input#image_integer[name=?]', "image[integer]")
      with_tag('input#image_integer[name=?]', "image[integer]")
      with_tag('input#image_string[name=?]', "image[string]")
    end
  end
end


