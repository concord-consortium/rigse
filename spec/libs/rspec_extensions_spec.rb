require 'spec_helper.rb'

describe "fails_in_themes" do
  it "should fail when there's no body" do
    lambda {
      fails_in_themes
    }.should raise_error(Exception)
  end

  describe "example passes" do
    it "should pass when the body passes and we're not running a matching theme" do
      ApplicationController.set_theme("xproject")
      fails_in_themes({ "assessment" => :todo }) do
        true.should be_true
      end
    end

    it "should fail when the example passes in the current theme, and the current theme is in :todo mode" do
      lambda {
        ApplicationController.set_theme("assessment")
        fails_in_themes({ "assessment" => :todo }) do
          true.should be_true
        end
      }.should raise_error(Spec::Example::PendingExampleFixedError)
    end

    it "should fail when the body passes in the current theme, and the current theme is in :expected mode" do
      ApplicationController.set_theme("assessment")
      lambda {
        fails_in_themes({ "assessment" => :expected }) do
          true.should be_true
        end
      }.should raise_error(Spec::Example::PendingExampleFixedError)
    end
  end

  describe "example fails" do
    it "should fail when the body fails and we're not running a matching theme" do
      ApplicationController.set_theme("xproject")
      lambda {
        fails_in_themes({ "assessment" => :todo }) do
          true.should be_false
        end
      }.should raise_error(Spec::Expectations::ExpectationNotMetError)
    end

    it "should be pending when the body fails in the current theme, and the current theme is set to :todo mode" do
      ApplicationController.set_theme("assessment")
      lambda {
        fails_in_themes({ "assessment" => :todo }) do
          true.should be_false
        end
      }.should raise_error(Spec::Example::ExamplePendingError)
    end

    it "should pass when the body fails in the current theme, and the current theme is set to :expected mode" do
      ApplicationController.set_theme("assessment")
      fails_in_themes({ "assessment" => :expected }) do
        true.should be_false
      end
    end
  end
end
