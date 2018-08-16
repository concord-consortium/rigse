require 'spec_helper'

describe ApplicationHelper do
  include ApplicationHelper
  attr_accessor :page_title

  describe "title" do
    it "should set @page_title" do
      expect(title_tag('hello')).to be_nil
      expect(page_title).to eql('hello')
    end

    it "should output container if set" do
      expect(title_tag('hello', :h2)).to have_selector('h2', :text => 'hello')
    end
  end

  describe "login_line" do
    before(:each) do
      @anonymous_user = mock_model(User, :roles => ["guest"], :anonymous? => true, :name => "guest")
      @admin_user = mock_model(User, :roles => ["admin"], :anonymous? => false, :name => "admin", :has_role? => true)
    end

    describe "as anonymous" do
      before(:each) do
        allow(self).to receive(:current_visitor).and_return(@anonymous_user)
        @original_user = @anonymous_user
      end
      it "should display appropriate login messages" do
        expect(login_line).to match(/login/i)
        expect(login_line).not_to match(/welcome/i)
        expect(login_line(:guest => "guest")).to match(/welcome\s*guest/i)
        expect(login_line(:login => "Log In")).to match(/Log In/)
        expect(login_line(:signup => "Sign Up")).to match(/Sign Up/)
      end
    end

    describe "as admin" do
      before(:each) do
        allow(self).to receive(:current_visitor).and_return(@admin_user)
        @original_user = @admin_user
      end
      it "should display appropriate login messages" do
        expect(login_line).to match(/log\s*out/i)
        expect(login_line).to match(/switch/i)
        expect(login_line(:logout => "Log Out")).to match(/Log Out/)
      end
    end
  end
end
