require File.expand_path('../../spec_helper', __FILE__)

describe "fails_in_themes" do
  before (:all) do
    @orig_theme = ApplicationController.get_theme
  end

  after (:all) do
    ApplicationController.set_theme(@orig_theme)
  end

  it "should fail when there's no body" do
    lambda {
      fails_in_themes
    }.should raise_error(Exception)
  end

  describe "when the example passes" do
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

  describe "when the example fails" do
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

  describe "capturing should_receive" do
    it "should catch mock verifications as test errors, and pass" do
      ApplicationController.set_theme("assessment")
      fails_in_themes({ "assessment" => :expected }) do
        ApplicationController.should_receive(:foo).once
      end
    end

    it "should not catch mock verifications it does not wrap" do
      lambda {
        ApplicationController.set_theme("assessment")
        ApplicationController.should_receive(:foo).once
        fails_in_themes({ "assessment" => :expected }) do
          true.should be_false
        end
        ApplicationController.rspec_verify
      }.should raise_error(Spec::Mocks::MockExpectationError)
    end
  end
end
