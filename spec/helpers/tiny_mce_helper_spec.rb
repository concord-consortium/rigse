require 'spec_helper'

describe TinyMceHelper do
  include TinyMceHelper

  describe "with default settings" do
    before(:each) do
      APP_CONFIG[:tiny_mce] = nil # remove project settings
    end

    it "should have default settings for buttons" do
      buttons = mce_buttons(1)
      buttons.should match default_mce_buttons(1)
    end
  end
  
  describe "witch project settings" do
    before(:each) do
      @line1 = "app_1a,app_1b"
      @line2 = "app_1c,app_1d"
      @line3 = "app_2a,app_2b,app_2c,|,app_2d"

      # setup project settings
      APP_CONFIG[:tiny_mce] = {
        :buttons1 => [@line1,@line2],
        :buttons2 =>  @line3
      }
    end
    
    it "should use application settings for tiny_mce buttons" do
      buttons = mce_buttons(1)
      buttons.should_not match default_mce_buttons(1)
      buttons.should match(@line1)
      buttons.should match(@line2)
      buttons.should match("|") # seperator for button sets.
    end

  end

end



