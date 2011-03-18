require 'spec_helper'

describe "/investigations/index.html.haml" do
  include InvestigationsHelper

  before(:each) do
    generate_default_project_and_jnlps_with_mocks
    logout_user
    login_researcher
    @inv1 = Factory.create(:investigation)
    @inv2 = Factory.create(:investigation)
    @inv3 = Factory.create(:investigation)
    assigns[:investigations] = @investigations = [@inv3,@inv2,@inv1]
  end

  it "should have a global usage report link" do
    render
    response.should have_tag("div[id=?]", "offering_list") do
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
    response.should have_tag("div[id=?]", "offering_list") do
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
    response.should have_tag("div[id*=?]", /^investigation_content_investigation_\d+$/) do
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
    response.should have_tag("div[id*=?]", /^investigation_content_investigation_\d+$/) do
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
