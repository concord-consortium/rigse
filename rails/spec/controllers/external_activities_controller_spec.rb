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

  let (:existing) { FactoryBot.create(:external_activity, {
      :name        => name,
      :long_description => description,
      :url         => url,
      :publication_status => 'published',
      :template    => FactoryBot.create(:activity, {
        :investigation => FactoryBot.create(:investigation)
      })
    })}

  let (:another) { FactoryBot.create(:external_activity, {
      :name        => "#{name} again",
      :long_description => "#{description} again",
      :url         => url,
      :publication_status => 'published',
      :is_official => false
    }) }

  def make(let_expression); end # Syntax sugar for our lets

  def collection(factory, count=3, opts={})
    results = []
    count.times do
      yield opts if block_given?
      results << FactoryBot.create(factory.to_sym, opts)
    end
    results
  end

  before(:each) do
    @current_settings = double(
      :name => "test settings",
      :use_student_security_questions => false,
      :use_bitmap_snapshots? => false,
      :require_user_consent? => false,
      :default_cohort => nil)
    allow(Admin::Settings).to receive(:default_settings).and_return(@current_settings)
    allow(controller).to receive(:before_render) {
      allow(response.template).to receive(:net_logo_package_name).and_return("blah")
      allow(response.template).to receive_message_chain(:current_settings).and_return(@current_settings);
    }

    @admin_user = login_admin
  end

  describe "#show" do
    it "should assign the activity correctly" do
      get :show, :id => existing.id
      result = assigns(:external_activity)
      expect(result.name).to eq(existing.name)
    end
  end

  describe "#publish" do

    context "when no version information is in the request" do
      describe "when no existing external_activity exists" do
        it "should create a new activity" do
          raw_post :publish, {}, activity_hash.to_json
          created = assigns(:external_activity)
          expect(created).not_to be_nil
          expect(created.name).to eq(name)
          expect(created.url).to  eq(url)
          expect(created.id).not_to eq(existing.id)
        end
      end

      describe "when an existing external_activity does exist" do
        it "should update the existing activity" do
          existing
          raw_post :publish, {}, activity_hash.to_json
          created = assigns(:external_activity)
          expect(created).not_to be_nil
          expect(created.name).to eq(name)
          expect(created.url).to  eq(url)
          expect(created.id).to   eq(existing.id)
          # See spec/lib/activity_runtime_api_spec.rb for more update tests
          expect(created.template.sections.size).to eq(1)
          expect(created.template.pages.size).to eq(1)
          expect(created.template.open_responses.size).to eq(1)
          expect(created.template.multiple_choices.size).to eq(1)
        end
      end
    end

    context "when version 2 of the API is requested" do

      let (:existing_sequence) { FactoryBot.create(:external_activity, {
          :name => sequence_name,
          :long_description => sequence_desc,
          :url => sequence_url,
          :template => FactoryBot.create(:investigation)
        }) }

      describe "when there is no existing external_activity" do
        it "should create a new activity" do
          raw_post :publish, { :version => 'v2' }, activity2_hash.to_json
          created = assigns(:external_activity)
          expect(created).not_to be_nil
          expect(created.name).to eq(name)
          expect(created.url).to  eq(url)
          expect(created.id).not_to eq(existing.id)
          expect(created.template).to be_an_instance_of(Activity)
        end
      end

      describe "when there is already an existing external_activity" do
        it "should update the existing activity" do
          existing
          raw_post :publish, { :version => 'v2' }, activity2_hash.to_json
          created = assigns(:external_activity)
          expect(created).not_to be_nil
          expect(created.name).to eq(name)
          expect(created.url).to  eq(url)
          expect(created.id).to   eq(existing.id)
          # See spec/lib/activity_runtime_api_spec.rb for more update tests
          expect(created.template.sections.size).to eq(1)
          expect(created.template.pages.size).to eq(1)
          expect(created.template.open_responses.size).to eq(1)
          expect(created.template.multiple_choices.size).to eq(1)
        end
      end

      describe "when no external_activity exists for the sequence" do
        it 'should create a new external activity with an investigation template' do
          sequence_hash['url'] = 'http://activity.org/sequence/2'
          raw_post :publish, { :version => 'v2' }, sequence_hash.to_json
          created = assigns(:external_activity)
          expect(created).not_to be_nil
          expect(created.name).to eq(sequence_name)
          expect(created.url).to  eq('http://activity.org/sequence/2')
          expect(created.id).not_to eq(existing_sequence.id)
          expect(created.template).to be_an_instance_of(Investigation)
        end
      end

      describe "when an external_activity already exists for the sequence" do
        it 'should update the existing external_activity' do
          existing_sequence
          raw_post :publish, { :version => 'v2' }, sequence_hash.to_json
          updated = assigns(:external_activity)
          expect(updated).not_to be_nil
          expect(updated.name).to eq(sequence_name)
          expect(updated.url).to  eq(sequence_url)
          expect(updated.id).to   eq(existing_sequence.id)
          # More about the updated sequence?
        end
      end
    end
  end

  describe "PUT update_collections" do
    let(:chemistry_activity)    { FactoryBot.create(:external_activity, :name => 'chemistry_activity', :url => "http://concord.org", :publication_status => 'published', :is_official => true) }
    let(:materials_collection)  { FactoryBot.create(:materials_collection) }

    it "should add materials to a collection" do
      post_params = {
          :materials_collection_id => [materials_collection.id]
      }
      admin = FactoryBot.generate :admin_user
      sign_in admin
      put :update_collections, post_params

      materials_collection_items = MaterialsCollectionItem.where(materials_collection_id: materials_collection.id)
      expect(materials_collection_items.length).to be(1)
      expect(flash[:notice]).to be_present
      expect(flash[:notice]).to match(/is assigned to the selected collection\(s\) successfully/)
    end

    it "should return an error if a collection is not specified" do
      post_params = {
          :materials_collection_id => []
      }
      admin = FactoryBot.generate :admin_user
      sign_in admin
      put :update_collections, post_params

      expect(flash[:error]).to be_present
      expect(flash[:error]).to match(/Select at least one collection to assign this resource/)
    end
  end

  describe 'SSL Helper' do
    let(:our_url)    { {} }
    let(:opts)       { {} }

    before(:each) do
      allow(controller).to receive_message_chain(:request, :url) { our_url }
    end

    it "url is set" do
      expect(controller.request.url).to eq our_url
    end

    describe "ssl_if_we_are" do
      let(:urls) do
        [ "http://blarg.com/path", "https://foo.com/blorp",
          "http://bingo.com/thing?query" ]
      end

      describe "when we are using ssl" do
        let(:our_url) { "https://ssl.com/path"}
        it "should return https urls always" do
          urls.each do |u|
            uri = URI.parse(u)
            uri = controller.send(:ssl_if_we_are, uri)
            expect(uri.scheme).to eq 'https'
          end
        end
      end

      describe "When we are not using ssl" do
        let(:our_url) { "http://nossl.com/path"}
        it "should return the original scheme" do
          urls.each do |u|
            o_uri = URI.parse(u)
            uri = controller.send(:ssl_if_we_are, o_uri)
            expect(uri.scheme).to eq o_uri.scheme
          end
        end
      end
    end
  end


  # TODO: auto-generated
  describe '#preview_index' do
    it 'GET preview_index' do
      get :preview_index, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#show' do
    it 'GET show' do
      get :show, id: FactoryBot.create(:external_activity).to_param

      expect(response).to have_http_status(:redirect)
    end

    it 'GET show' do
      FactoryBot.create(:external_activity, uuid: 'a' * 36)

      get :show, id: 'a' * 36

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#edit' do
    it 'GET edit' do
      get :edit, id: FactoryBot.create(:external_activity).to_param

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#create' do
    it 'POST create' do
      post :create, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#destroy' do
    it 'DELETE destroy' do
      delete :destroy, id: FactoryBot.create(:external_activity).to_param

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#republish' do
    it 'GET republish' do
      get :republish, {}, {}

      expect(response).to have_http_status(:unauthorized)
    end
  end

  # TODO: auto-generated
  describe '#matedit' do
    it 'GET matedit' do
      get :matedit, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#archive' do
    it 'GET archive' do
      get :archive, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#unarchive' do
    it 'GET unarchive' do
      get :unarchive, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#set_private_before_matedit' do
    it 'GET set_private_before_matedit' do
      get :set_private_before_matedit, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#copy' do
    it 'GET copy' do
      get :copy, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end
end
