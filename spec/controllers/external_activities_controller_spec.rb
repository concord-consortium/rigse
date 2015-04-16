require File.expand_path('../../spec_helper', __FILE__)#include ApplicationHelper


describe ExternalActivitiesController do

  let(:name)        { "Cool Activity"                  }
  let(:description) { name                             }
  let(:url )        { "http://activity.com/activity/1" }
  let(:launch_url)  { "#{url}/1/sessions/"             }

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

  let (:activity2_hash) do
    a2hash = activity_hash
    a2hash['type'] = 'Activity'
    a2hash
  end

  let (:sequence_name) { "Many fun things" }
  let (:sequence_desc) { "Several activities together in a sequence" }
  let (:sequence_url)  { "http://activity.com/sequence/1" }

  let (:sequence_hash) do
    {
      "type" => "Sequence",
      "name" => sequence_name,
      "description" => sequence_desc,
      "url" => sequence_url,
      "launch_url" => sequence_url,
      "activities" => [activity2_hash]
    }
  end

  let (:existing) { Factory.create(:external_activity, {
      :name        => name,
      :description => description,
      :url         => url,
      :publication_status => 'published',
      :template    => Factory.create(:activity, {
        :investigation => Factory.create(:investigation)
      })
    })}

  let (:another) { Factory.create(:external_activity, {
      :name        => "#{name} again",
      :description => "#{description} again",
      :url         => url,
      :publication_status => 'published',
      :is_official => false
    }) }

  def make(let_expression); end # Syntax sugar for our lets

  def collection(factory, count=3, opts={})
    results = []
    count.times do
      yield opts if block_given?
      results << FactoryGirl.create(factory.to_sym, opts)
    end
    results
  end

  before(:each) do
    @current_settings = mock(
      :name => "test settings",
      :using_custom_css? => false,
      :use_student_security_questions => false,
      :use_bitmap_snapshots? => false,
      :require_user_consent? => false)
    Admin::Settings.stub!(:default_settings).and_return(@current_settings)
    controller.stub(:before_render) {
      response.template.stub(:net_logo_package_name).and_return("blah")
      response.template.stub_chain(:current_settings).and_return(@current_settings);
    }

    @admin_user = login_admin
  end

  describe '#index' do
    # material browsing & searching is handled search_controller.rb
    # one idea: show only the current users list?
    it "should material indexes display anything?"
  end

  describe "#show" do
    it "should assign the activity correctly" do
      get :show, :id => existing.id
      result = assigns(:external_activity)
      result.name.should == existing.name
    end
  end

  describe "#publish" do

    context "when no version information is in the request" do
      describe "when no existing external_activity exists" do
        it "should create a new activity" do
          raw_post :publish, {}, activity_hash.to_json
          created = assigns(:external_activity)
          created.should_not be_nil
          created.name.should == name
          created.url.should  == url
          created.id.should_not == existing.id
        end
      end

      describe "when an existing external_activity does exist" do
        it "should update the existing activity" do
          existing
          raw_post :publish, {}, activity_hash.to_json
          created = assigns(:external_activity)
          created.should_not be_nil
          created.name.should == name
          created.url.should  == url
          created.id.should   == existing.id
          # See spec/lib/activity_runtime_api_spec.rb for more update tests
          created.template.sections.should have(1).section
          created.template.pages.should have(1).page
          created.template.open_responses.should have(1).open_response
          created.template.multiple_choices.should have(1).multiple_choice
        end
      end
    end

    context "when version 2 of the API is requested" do

      let (:existing_sequence) { Factory.create(:external_activity, {
          :name => sequence_name,
          :description => sequence_desc,
          :url => sequence_url,
          :template => Factory.create(:investigation)
        }) }

      describe "when there is no existing external_activity" do
        it "should create a new activity" do
          raw_post :publish, { :version => 'v2' }, activity2_hash.to_json
          created = assigns(:external_activity)
          created.should_not be_nil
          created.name.should == name
          created.url.should  == url
          created.id.should_not == existing.id
          created.template.should be_an_instance_of(Activity)
        end
      end

      describe "when there is already an existing external_activity" do
        it "should update the existing activity" do
          existing
          raw_post :publish, { :version => 'v2' }, activity2_hash.to_json
          created = assigns(:external_activity)
          created.should_not be_nil
          created.name.should == name
          created.url.should  == url
          created.id.should   == existing.id
          # See spec/lib/activity_runtime_api_spec.rb for more update tests
          created.template.sections.should have(1).section
          created.template.pages.should have(1).page
          created.template.open_responses.should have(1).open_response
          created.template.multiple_choices.should have(1).multiple_choice
        end
      end

      describe "when no external_activity exists for the sequence" do
        it 'should create a new external activity with an investigation template' do
          sequence_hash['url'] = 'http://activity.org/sequence/2'
          raw_post :publish, { :version => 'v2' }, sequence_hash.to_json
          created = assigns(:external_activity)
          created.should_not be_nil
          created.name.should == sequence_name
          created.url.should  == 'http://activity.org/sequence/2'
          created.id.should_not == existing_sequence.id
          created.template.should be_an_instance_of(Investigation)
        end
      end

      describe "when an external_activity already exists for the sequence" do
        it 'should update the existing external_activity' do
          existing_sequence
          raw_post :publish, { :version => 'v2' }, sequence_hash.to_json
          updated = assigns(:external_activity)
          updated.should_not be_nil
          updated.name.should == sequence_name
          updated.url.should  == sequence_url
          updated.id.should   == existing_sequence.id
          # More about the updated sequence?
        end
      end
    end
  end

end
