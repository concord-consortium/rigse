require 'spec_helper'

include ApplicationHelper
describe RunnablesHelper do
  include RunnablesLinkMatcher
  before :each do
    @anonymous_user = mock_model(User, :roles => ["guest"], :anonymous? => true, :name => "guest")
    @anonymous_user.stub!(:extra_params).and_return({})
    helper.stub!(:current_visitor).and_return(@anonymous_user)
    helper.stub!(:authenticate_with_http_basic).and_return nil
    @resource_page = stub_model(ResourcePage, :name => "Foo")
  end

  describe ".display_workgroups_run_link?" do
    context "with workgroups enabled" do
      before :each do
        helper.stub!(:use_adhoc_workgroups?).and_return true
      end

      context "with a jnlp launchable" do
        let :offering do
          runnable = Object.new().extend(JnlpLaunchable)
          mock(:runnable => runnable)
        end
        it "should return true" do
          helper.display_workgroups_run_link?(offering).should be_true
        end
      end
      context "with non-jlnp launchables" do
        let :offering do
          mock(:runnable => Object.new)
        end
        it "should return false" do
          helper.display_workgroups_run_link?(offering).should be_false
        end
      end
    end

    context "with workgroups disabled" do
      before :each do
        helper.stub!(:use_adhoc_workgroups?).and_return false
      end

      context "with a jnlp launchable" do
        let :offering do
          mock(:runnable => Object.new().extend(JnlpLaunchable))
        end
        it "should return false" do
          helper.display_workgroups_run_link?(offering).should be_false
        end
      end
    end
  end

  describe ".display_status_updates?" do
      context "with an offering that can update statuses" do
        let :offering do
          mock(:runnable => mock(:has_update_status? => true))
        end
        it "should return true" do
          helper.display_status_updates?(offering).should be_true
        end
      end
      context "with simpler offering" do
        let :offering do
          mock(:runnable => Object.new())
        end
        it "should return false" do
          helper.display_status_updates?(offering).should be_false
        end
      end

  end

  describe ".student_run_buttons" do

  end

  describe ".run_button_for" do
    it "should render a run button for a specified component" do
      helper.run_button_for(@resource_page).should be_link_like("http://test.host/resource_pages/#{@resource_page.id}",
                                                                "run_link rollover",
                                                                asset_path("run.png"))
    end
  end

  describe ".preview_button_for" do
    it "should render a preview button for a specified component" do
      helper.preview_button_for(@resource_page).should be_link_like("http://test.host/resource_pages/#{@resource_page.id}",
                                                                    "run_link rollover",
                                                                    asset_path("preview.png"))
    end
  end

  describe ".teacher_preview_button_for" do
    it "should render a preview button in techer mode for a given component" do
      helper.teacher_preview_button_for(@resource_page).should be_link_like("http://test.host/resource_pages/#{@resource_page.id}",
                                                                             "run_link rollover",
                                                                             asset_path("teacher_preview.png"))
    end
  end

  describe ".preview_link_for" do
    it "should render a preview link for a given component" do
      helper.preview_link_for(@resource_page).should be_link_like("http://test.host/resource_pages/#{@resource_page.id}",
                                                                  "run_link rollover",
                                                                  asset_path("preview.png"),
                                                                  "preview")
    end

    it "should render a preview link for a given component with parameters" do
      link_text = "run Jeff's Leiderhosen"
      helper.preview_link_for(@resource_page,
                              nil,
                              {:link_text => link_text}).
                              should be_link_like("http://test.host/resource_pages/#{@resource_page.id}",
                                                  "run_link rollover",
                                                  asset_path("preview.png"),
                                                  link_text)
    end
  end

  describe ".run_link_for" do
    it "should render a run link for a given component" do
      helper.run_link_for(@resource_page).should be_link_like("http://test.host/resource_pages/#{@resource_page.id}",
                                                              "run_link rollover",
                                                              asset_path("run.png"),
                                                              "run")
    end

    it "should render a run link for a given component with parameters" do
      link_text = "run Biscuits"
      helper.run_link_for(@resource_page,
                          nil,
                          {:link_text => "run Biscuits"}).
                          should be_link_like("http://test.host/resource_pages/#{@resource_page.id}",
                                               "run_link rollover",
                                               asset_path("run.png"),
                                               link_text)
    end

    it "should render a link for a Resource Page Offering" do
      offering = mock_model(Portal::Offering, :name => "The Pajama Jammy Jam")
      offering.stub!(:runnable).and_return(stub_model(ResourcePage))
      offering.stub!(:resource_page?).and_return true
      helper.run_link_for(offering).should == "<a href=\"/resource_pages/#{offering.runnable.id}\">View The Pajama Jammy Jam</a>"
    end

    it "should render a link for an External Activity" do
      ext_act = stub_model(ExternalActivity, :name => "Fetching Wood")
      helper.run_link_for(ext_act).should be_link_like("http://test.host/external_activities/#{ext_act.id}.run_external_html",
                                                       "run_link rollover",
                                                       asset_path("run.png"))
    end

    it "should render a link for a Page as a JNLP launchable" do
      page = stub_model(Page, :name => "Fun With Hippos")
      helper.run_link_for(page).should be_link_like("http://test.host/pages/#{page.id}.jnlp",
                                                    "run_link rollover",
                                                    asset_path("run.png"))
    end

    it "should render a link for an Investigation as a JNLP launchable" do
      investigation = stub_model(Investigation, :name => "Searching for Stars")
      helper.run_link_for(investigation).should be_link_like("http://test.host/investigations/#{investigation.id}.jnlp",
                                                             "run_link rollover",
                                                             asset_path("run.png"))
    end

    it "should render a link for a Investigation Offering" do
      offering = mock_model(Portal::Offering, :name => "Investigation Offering")
      investigation = stub_model(Investigation)
      offering.stub!(:runnable).and_return(investigation)
      offering.stub!(:resource_page?).and_return false
      offering.stub!(:run_format).and_return :jnlp
      offering.stub!(:external_activity?).and_return false
      helper.run_link_for(offering).should be_link_like("http://test.host/users/#{@anonymous_user.id}/portal/offerings/#{offering.id}.jnlp",
                                                             "run_link rollover",
                                                             asset_path("run.png"))
    end

    it "should render a link for an Activity as a JNLP launchable" do
      activity = stub_model(Activity, :name => "Fun in the Garden")
      helper.run_link_for(activity).should be_link_like("http://test.host/activities/#{activity.id}.jnlp",
                                                        "run_link rollover",
                                                        asset_path("run.png"))
    end

    it "should render a link for a Section as a JNLP launchable" do
      section = stub_model(Section, :name => "Learning About Taxidermy")
      helper.run_link_for(section).should be_link_like("http://test.host/sections/#{section.id}.jnlp",
                                                       "run_link rollover",
                                                       asset_path("run.png"))
    end
  end
end
