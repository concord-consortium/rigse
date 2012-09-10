require 'spec_helper'

describe OtmlHelper do
  include OtmlHelper

#   def otml_css_path(base="stylesheets",name="otml")
#    theme = APP_CONFIG[:theme]
#    file = "#{name}.css"
#    default_path = File.join(base,file)
#    if theme
#      themed_path = File.join(base,'themes', theme, file)
#      if File.exists? File.join(Rails.root,'public',themed_path)
#        return "/#{themed_path}"
#      end
#    end
#    return "/#{default_path}"
#  end

  describe "otml_css_path" do
    
    describe "without a theme" do
      before(:all) do
        @theme = APP_CONFIG[:theme]
        APP_CONFIG[:theme] = nil
      end
      after(:all) do
        APP_CONFIG[:theme] = @theme
      end
      
      it "should return the default otml.css path" do
        otml_css_path.should eql("/assets/otml.css")
      end

    end
    
    describe "with a theme" do
      before(:all) do
        @theme_name = "fakeo"
        @theme = APP_CONFIG[:theme]
        APP_CONFIG[:theme] = @theme_name
        File.stub!(:exists? => true)
      end

      after(:all) do
        APP_CONFIG[:theme] = @theme
      end
      
      it "should return the themed otml.css path" do
        otml_css_path.should eql("/assets/#{@theme_name}/stylesheets/otml.css")
      end

    end
  end

  # this is *not* an asset URL. There is a named route in routes.rb
  # this test is just here as documentation
  describe "otml_project_css_path" do
    it "should return /stylesheets/project.css (always)" do
      otml_project_css_path.should eql("/stylesheets/project.css")
    end

  end
end



