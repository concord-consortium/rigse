require 'spec_helper'

describe OtmlHelper do
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
      end

      after(:all) do
        APP_CONFIG[:theme] = @theme
      end

      it "should call theme_stylesheet_path when there is a theme" do
        helper.stub!(:theme_stylesheet_path => '/fakeo-path')
        helper.otml_css_path.should eql("/fakeo-path")
      end

      it "should return the default otml stylesheet if it can't find a themed one" do
        # note this might start failing if the asset configuration is changed for the test environment
        helper.otml_css_path.should eql("/assets/otml.css")
      end
    end
  end

  # this is *not* an asset URL. There is a named route in routes.rb
  # this test is just here as documentation
  describe "otml_settings_css_path" do
    it "should return /stylesheets/settings.css (always)" do
      otml_settings_css_path.should eql("/stylesheets/settings.css")
    end

  end
end



