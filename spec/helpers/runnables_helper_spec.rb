require 'spec_helper'

include ApplicationHelper
describe RunnablesHelper do
  include RunnablesLinkMatcher
  before :each do
    @anonymous_user = mock_model(User, :roles => ["guest"], :anonymous? => true, :name => "guest")
    @anonymous_user.stub!(:extra_params).and_return({})
    helper.stub!(:current_user).and_return(@anonymous_user)
    helper.stub!(:authenticate_with_http_basic).and_return nil
    @resource_page = mock_model(ResourcePage, :name => "Foo")
  end

  describe ".run_button_for" do
    it "should render a run button for a specified component" do
      helper.run_button_for(@resource_page).should be_link_like("http://test.host/resource_pages/#{@resource_page.id}.jnlp",
                                                                "run_link rollover",
                                                                "/images/run.png")
    end
  end

  describe ".preview_button_for" do
    it "should render a preview button for a specified component" do
      helper.preview_button_for(@resource_page).should be_link_like("http://test.host/resource_pages/#{@resource_page.id}.jnlp",
                                                                    "run_link rollover",
                                                                    "/images/preview.png")
    end
  end

  describe ".teacher_preview_button_for" do
    it "should render a preview button in techer mode for a given component" do
      helper.teacher_preview_button_for(@resource_page).should be_link_like("http://test.host/resource_pages/#{@resource_page.id}.jnlp",
                                                                             "run_link rollover",
                                                                             "/images/teacher_preview.png")
    end
  end

  describe ".preview_link_for" do
    it "should render a preview link for a given component" do
      helper.preview_link_for(@resource_page).should be_link_like("http://test.host/resource_pages/#{@resource_page.id}.jnlp",
                                                                  "run_link rollover",
                                                                  "/images/preview.png",
                                                                  "preview")
    end

    it "should render a preview link for a given component with parameters" do
      link_text = "run Jeff's Leiderhosen"
      helper.preview_link_for(@resource_page,
                              nil,
                              {:link_text => link_text}).
                              should be_link_like("http://test.host/resource_pages/#{@resource_page.id}.jnlp",
                                                  "run_link rollover",
                                                  "/images/preview.png",
                                                  link_text)
    end
  end

  describe ".run_link_for" do
    it "should render a run link for a given component" do
      helper.run_link_for(@resource_page).should be_link_like("http://test.host/resource_pages/#{@resource_page.id}.jnlp",
                                                              "run_link rollover",
                                                              "/images/run.png",
                                                              "run")
    end

    it "should render a run link for a given component with parameters" do
      link_text = "run Biscuits"
      helper.run_link_for(@resource_page,
                          nil,
                          {:link_text => "run Biscuits"}).
                          should be_link_like("http://test.host/resource_pages/#{@resource_page.id}.jnlp",
                                               "run_link rollover",
                                               "/images/run.png",
                                               link_text)
    end

    it "should render a link for a resource page" do
      offering = mock_model(Portal::Offering, :name => "The Pajama Jammy Jam")
      offering.stub!(:runnable).and_return(mock_model(ResourcePage))
      offering.stub!(:resource_page?).and_return true
      helper.run_link_for(offering).should == "<a href=\"/resource_pages/#{offering.runnable.id}\" target=\"_blank\">View The Pajama Jammy Jam</a>"
    end

    it "should render a link for a JNLP type" do
      page = mock_model(Page, :name => "Fun With Hippos")
      helper.run_link_for(page).should be_link_like("http://test.host/pages/#{page.id}",
                                                    "run_link rollover",
                                                    "/images/run.png")
    end
  end
end
