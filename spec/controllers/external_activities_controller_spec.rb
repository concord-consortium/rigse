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
      :url         => existing_url,
      :publication_status => 'published',
      :template    => Factory.create(:activity, {
        :investigation => Factory.create(:investigation)
      })
    })}

  let (:another) { Factory.create(:external_activity, {
      :name        => "#{name} again",
      :description => "#{description} again",
      :url         => existing_url,
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
  end

  describe '#index' do
    before(:each) do
      @double_search = double(Search)
      Search.stub!(:new).and_return(@double_search)
    end

    context 'when the user is an author' do
      before(:each) do
        @current_visitor = login_author
      end

      it "should show only public, official, and user-owned activities" do
        @double_search.stub(:results => {:all => [existing, another]})
        # Expect the double to be called with certain params
        Search.should_receive(:new).with({ :material_types => [ExternalActivity], :page => nil, :private => true, :user_id => @current_visitor.id }).and_return(@double_search)
        get :index
        assigns[:external_activities].length.should be(2) # Because that's what Search#results[:all] is stubbed to return
      end
    end

    context 'when the user is an admin' do
      it "should show all activities" do
        @double_search.stub(:results => {:all => [existing, another]})
        Search.should_receive(:new).with({ :material_types => [ExternalActivity], :page => nil }).and_return(@double_search)
        get :index
        assigns[:external_activities].length.should be(2) # Because that's what Search#results[:all] is stubbed to return
      end

      it 'filters activities by keyword when provided' do
        @double_search.stub(:results => {:all => [existing]})
        Search.should_receive(:new).with({ :material_types => [ExternalActivity], :page => nil, :search_term => 'again' }).and_return(@double_search)
        get :index, {:name => 'again'}
        assigns[:external_activities].length.should be(1)
      end

      it 'shows drafts when box is checked' do
        pending "Do we still want this box?"
        # TODO: Expect the double to be called with certain params
      end
    end
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
        let(:existing_url) { url }
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
        let(:existing_url) { url }
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
