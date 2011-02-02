require 'spec_helper'

describe ApplicationHelper do
  include ApplicationHelper
  attr_accessor :page_title

  describe "title" do
    it "should set @page_title" do
      title('hello').should be_nil
      page_title.should eql('hello')
    end

    it "should output container if set" do
      title('hello', :h2).should have_tag('h2', 'hello')
    end
  end

  describe "login_line" do
    before(:each) do
      @anonymous_user = mock_model(User, :roles => ["guest"], :anonymous? => true, :name => "guest")
      @admin_user = mock_model(User, :roles => ["admin"], :anonymous? => false, :name => "admin", :has_role? => true)
    end

    describe "as anonymous" do
      before(:each) do
        stub!(:current_user).and_return(@anonymous_user)
        @original_user = @anonymous_user
      end
      it "should display appropriate login messages" do
        login_line.should match(/login/i)
        login_line.should_not match(/welcome/i)
        login_line(:guest => "guest").should match(/welcome\s*guest/i)
        login_line(:login => "Log In").should match(/Log In/)
        login_line(:signup => "Sign Up").should match(/Sign Up/)
      end
    end

    describe "as admin" do
      before(:each) do
        stub!(:current_user).and_return(@admin_user)
        @original_user = @admin_user
      end
      it "should display appropriate login messages" do
        login_line.should match(/log\s*out/i)
        login_line.should match(/switch/i)
        login_line(:logout => "Log Out").should match(/Log Out/)
      end
    end
  end
end
