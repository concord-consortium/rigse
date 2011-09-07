require 'spec_helper'

describe "/investigations/index.html.haml" do
  include InvestigationsHelper

  before(:each) do
    @inv1 = Factory.create(:investigation)
    @inv2 = Factory.create(:investigation)
    @inv3 = Factory.create(:investigation)
    assigns[:investigations] = @investigations = [@inv3,@inv2,@inv1]
    view.stub!(:current_user).and_return(Factory.next(:researcher_user))
  end

  it "should have a global usage report link" do
    render
    assert_select("div[id=?]", "offering_list") do
      assert_select("div[class=?]", "action_menu") do
        assert_select("div[class=?]", "action_menu_header") do
          assert_select("div[class=?]", "action_menu_header_right") do
            assert_select("ul[class=?]", "menu") do
              assert_select("li[class=?] > a", "menu", "Usage Report")
            end
          end
        end
      end
    end
  end

  it "should have a global details report link" do
    render
    assert_select("div[id=?]", "offering_list") do
      assert_select("div[class=?]", "action_menu") do
        assert_select("div[class=?]", "action_menu_header") do
          assert_select("div[class=?]", "action_menu_header_right") do
            assert_select("ul[class=?]", "menu") do
              assert_select("li[class=?] > a", "menu", "Details Report")
            end
          end
        end
      end
    end
  end

  it "should have an individual usage report link" do
    render
    assert_select("div[id*=?]", /^investigation_content_investigation_\d+$/) do
      assert_select("div[class=?]", "action_menu") do
        assert_select("div[class=?]", "action_menu_header_right") do
          assert_select("ul[class=?]", "menu") do
            assert_select("li[class=?] > a", "menu", "Usage Report")
          end
        end
      end
    end
  end

  it "should have an individual details report link" do
    render
    assert_select("div[id*=?]", /^investigation_content_investigation_\d+$/) do
      assert_select("div[class=?]", "action_menu") do
        assert_select("div[class=?]", "action_menu_header_right") do
          assert_select("ul[class=?]", "menu") do
            assert_select("li[class=?] > a", "menu", "Details Report")
          end
        end
      end
    end
  end

end
