require 'spec_helper'

describe "/investigations/index.html.haml" do
  include InvestigationsHelper

  before(:each) do
    @inv1 = Factory.create(:investigation)
    @inv2 = Factory.create(:investigation)
    @inv3 = Factory.create(:investigation)
    assigns[:investigations] = @investigations = [@inv3,@inv2,@inv1]
    template.stub!(:current_user).and_return(Factory.next(:researcher_user))
  end

  it "should have a global usage report link" do
    render
    response.should have_selector("div[id=?]", "offering_list") do
      with_tag("div[class=?]", "action_menu") do
        with_tag("div[class=?]", "action_menu_header") do
          with_tag("div[class=?]", "action_menu_header_right") do
            with_tag("ul[class=?]", "menu") do
              with_tag("li[class=?] > a", "menu", "Usage Report")
            end
          end
        end
      end
    end
  end

  it "should have a global details report link" do
    render
    response.should have_selector("div[id=?]", "offering_list") do
      with_tag("div[class=?]", "action_menu") do
        with_tag("div[class=?]", "action_menu_header") do
          with_tag("div[class=?]", "action_menu_header_right") do
            with_tag("ul[class=?]", "menu") do
              with_tag("li[class=?] > a", "menu", "Details Report")
            end
          end
        end
      end
    end
  end

  it "should have an individual usage report link" do
    render
    response.should have_selector("div[id*=?]", /^investigation_content_investigation_\d+$/) do
      with_tag("div[class=?]", "action_menu") do
        with_tag("div[class=?]", "action_menu_header_right") do
          with_tag("ul[class=?]", "menu") do
            with_tag("li[class=?] > a", "menu", "Usage Report")
          end
        end
      end
    end
  end

  it "should have an individual details report link" do
    render
    response.should have_selector("div[id*=?]", /^investigation_content_investigation_\d+$/) do
      with_tag("div[class=?]", "action_menu") do
        with_tag("div[class=?]", "action_menu_header_right") do
          with_tag("ul[class=?]", "menu") do
            with_tag("li[class=?] > a", "menu", "Details Report")
          end
        end
      end
    end
  end

end
