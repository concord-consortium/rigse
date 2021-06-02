require 'spec_helper'

class ConsumerClass
  include ThemeHelper
end

def set_theme_env(name)
  allow(ENV).to receive(:[]).with(ThemeHelper::ENV_THEME_KEY).and_return(name)
end

def stub_env(key, value)
end

describe ThemeHelper do
  let(:theme_name)  { nil }
  let(:instance)    { ConsumerClass.new }

  it "ConsumerClass has ThemeHelper includes" do
    expect(ConsumerClass).to include(ThemeHelper)
  end

  describe "helper defined methods should exist" do
    it "should respond to :render_themed_partial" do
      expect(instance).to respond_to :render_themed_partial
    end
    it "should respond to :themed_style_sheet_tag" do
      expect(instance).to respond_to :themed_style_sheet_tag
    end
    it "should respond to :theme_name" do
      expect(instance).to respond_to :theme_name
    end
  end

  describe ":theme_name" do
    describe "with no theme name in the environment" do
      it "should return the default theme name" do
        set_theme_env(nil)
        expect(instance.theme_name).to eql 'learn'
        set_theme_env("")
        expect(instance.theme_name).to eql 'learn'
      end
    end
    describe "with theme name set in the environment" do
      it "should return the theme name" do
        set_theme_env('foo')
        expect(instance.theme_name).to eql 'foo'
      end
    end
  end

  describe ":render_themed_partial" do
    before(:each) { set_theme_env('learn') }

    describe "When the requested themed template exists" do
      it "should render the template" do
        allow(instance)
          .to receive_message_chain(:lookup_context, :template_exists?)
          .and_return(true)

        expect(instance).to receive(:render).with({ partial: 'themes/learn/foo' })
        instance.render_themed_partial('foo')
      end
    end

    describe "When the theme is missing the requested template)" do
      it "should render the default template" do
        allow(instance)
          .to receive_message_chain(:lookup_context, :template_exists?)
          .and_return(false)
        expect(instance).to receive(:render).with({ partial: 'foo' })
        instance.render_themed_partial('foo')
      end
    end
  end
end
