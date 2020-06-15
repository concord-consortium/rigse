require 'spec_helper'

describe TinyMceHelper, type: :helper do
  include TinyMceHelper

  describe "with default settings" do
    before(:each) do
      APP_CONFIG[:tiny_mce] = nil # remove settings
    end

    it "should have default settings for buttons" do
      buttons = mce_buttons(1)
      expect(buttons).to match default_mce_buttons(1)
    end
  end
  
  describe "with custom settings" do
    before(:each) do
      @line1 = "app_1a,app_1b"
      @line2 = "app_1c,app_1d"
      @line3 = "app_2a,app_2b,app_2c,|,app_2d"

      # setup settings
      APP_CONFIG[:tiny_mce] = {
        :buttons1 => [@line1,@line2],
        :buttons2 =>  @line3
      }
    end
    
    it "should use application settings for tiny_mce buttons" do
      buttons = mce_buttons(1)
      expect(buttons).not_to match default_mce_buttons(1)
      expect(buttons).to match(@line1)
      expect(buttons).to match(@line2)
      expect(buttons).to match("|") # seperator for button sets.
    end

  end


  # TODO: auto-generated
  describe '#mce_init_string' do
    it 'works' do
      result = helper.mce_init_string

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#default_mce_buttons' do
    it 'works' do
      result = helper.default_mce_buttons(3)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#mce_theme_buttons' do
    it 'works' do
      result = helper.mce_theme_buttons(3)

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#mce_buttons' do
    it 'works' do
      result = helper.mce_buttons(2)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#valid_elements' do
    it 'works' do
      result = helper.valid_elements

      expect(result).not_to be_nil
    end
  end


end
