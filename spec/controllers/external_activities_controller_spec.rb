require File.expand_path('../../spec_helper', __FILE__)#include ApplicationHelper


describe ExternalActivitiesController do
  let(:name)        { "Cool Activity"                  }
  let(:description) { name                             }
  let(:url )        { "http://activity.com/activity/1" }
  let(:launch_url)  { "#{url}/1/sessions/"             }
  let(:existing_url){ nil }

  let(:activity_hash) do
    {
      "name" => name,
      "url" => url,
      "launch_url" => launch_url,
      "sections" => [
        {
          "name" => "Cool Activity Section 1",
          "pages" => [
            {
              "name" => "Cool Activity Page 1",
              "elements" => [
                {
                  "type" => "open_response",
                  "id" => "1234568",
                  "prompt" => "Why do you like/dislike this activity?"
                },
                {
                  "type" => "image_question",
                  "id" => "12345689",
                  "prompt" => "Draw a picture of why this activity is awesome."
                },
                {
                  "type" => "multiple_choice",
                  "id" => "456789",
                  "prompt" => "What color is the sky?",
                  "allow_multiple_selection" => false,
                  "choices" => [
                    {
                      "id" => "97",
                      "content" => "red"
                    },
                    {
                      "id" => "98",
                      "content" => "blue",
                      "correct" => true
                    },
                    {
                      "id" => "99",
                      "content" => "greenish-green"
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  end

  before(:each) do
    @current_project = mock(
      :name => "test project",
      :using_custom_css? => false,
      :use_student_security_questions => false,
      :use_bitmap_snapshots? => false,
      :require_user_consent? => false)
    Admin::Project.stub!(:default_project).and_return(@current_project)
    controller.stub(:before_render) {
      response.template.stub(:net_logo_package_name).and_return("blah")
      response.template.stub_chain(:current_project).and_return(@current_project);
    }
    @admin_user = login_admin
    @existing = Factory.create(:external_activity, {
      :name        => name,
      :description => description,
      :url         => existing_url,
      :publication_status => 'published',
      :template    => Factory.create(:activity, {
        :investigation => Factory.create(:investigation)
      })
    })
    @another = Factory.create(:external_activity, {
      :name        => "#{name} again",
      :description => "#{description} again",
      :url         => existing_url,
      :publication_status => 'published',
      :is_official => false
    })
  end

  let(:activity) do

  end

  describe '#index' do
    context 'when the user is an author' do
      it "should show only public, official, and user-owned activities" do
        current_visitor = login_author
        get :index
        assigns[:external_activities].length.should be(ExternalActivity.published.count + ExternalActivity.by_user(current_visitor).count)
      end
    end

    context 'when the user is an admin' do
      it "should show all activities" do
        get :index
        assigns[:external_activities].length.should be(ExternalActivity.count)
      end
    end
  end

  describe "#show" do
    it "should assign the activity correctly" do
      get :show, :id => @existing.id
      result = assigns(:external_activity)
      result.name.should == @existing.name
    end
  end

  describe "#publish" do

    describe "when no existing external_activity exists" do
      it "should create a new activity" do
        raw_post :publish, {}, activity_hash.to_json
        created = assigns(:external_activity)
        created.should_not be_nil
        created.name.should == name
        created.url.should  == url
        created.id.should_not == @existing.id
      end
    end

    describe "when an existing external_activity does exist" do
      let(:existing_url) { url }
      it "should update the existing activity" do
        raw_post :publish, {}, activity_hash.to_json
        created = assigns(:external_activity)
        created.should_not be_nil
        created.name.should == name
        created.url.should  == url
        created.id.should   == @existing.id
        # See spec/lib/activity_runtime_api_spec.rb for more update tests
        created.template.sections.should have(1).section
        created.template.pages.should have(1).page
        created.template.open_responses.should have(1).open_response
        created.template.multiple_choices.should have(1).multiple_choice
      end
    end
  end

end
