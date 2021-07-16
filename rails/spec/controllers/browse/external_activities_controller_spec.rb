require 'spec_helper'

describe Browse::ExternalActivitiesController do

  let(:activity) { FactoryBot.create(:external_activity,
    :name => "test activity",
    :publication_status => "published") }

  let(:sequence) { FactoryBot.create(:external_activity,
    :name => "test sequence",
    :publication_status => "published") }

  let(:interactive) { FactoryBot.create(:interactive,
    :name => "test interactive",
    :publication_status => "published",
    :external_activity_id => activity.id ) }

    before(:each) do
        @author_user = FactoryBot.generate(:author_user)
        @external_activity = FactoryBot.create(:external_activity, :name => 'activity', :url => 'external.activity.org/1', :user => @author_user, :publication_status => 'published')
    end

    describe "GET show" do
      xit "should preview external activity details" do
         @post_params = {
          :search_term => @external_activity.name,
          :investigation_page=>1,
          :activity_page=>1,
          :id=>@external_activity.id
        }
        post :show, params: @post_params

        expect(assigns[:wide_content_layout]).to eq(true)

        expect(assigns[:back_to_search_url]).to match /.*search\?activity_page=1&investigation_page=1&search_term=#{@external_activity.name}$/
        expect(assigns[:search_material]).not_to be_nil
        expect(assigns[:search_material].material).to eq(@external_activity)
      end
    end

    describe "STEM resources" do  
      # note: in the tests below the "slug" param is always optional
      it "should return 200 when a valid activity is used" do
        get :show, params: { :id => activity.id }
        expect(response).to be_successful
        get :show, params: { :id => activity.id, :slug => "test" }
        expect(response).to be_successful
      end
  
      it "should return 404 when an unknown activity is used" do
        get :show, params: { :id => 999999999999999 }
        expect(response).not_to be_successful
        get :show, params: { :id => 999999999999999, :slug => "test" }
        expect(response).not_to be_successful
      end
  
      it "should return 200 when a valid sequence is used" do
        get :show, params: { :id => sequence.id }
        expect(response).to be_successful
        get :show, params: { :id => sequence.id, :slug => "test" }
        expect(response).to be_successful
      end
  
      it "should return 404 when an unknown sequence is used" do
        get :show, params: { :id => 999999999999999 }
        expect(response).not_to be_successful
        get :show, params: { :id => 999999999999999, :slug => "test" }
        expect(response).not_to be_successful
      end
  
      xit "should return 200 when a valid interactive is used" do
        get :show, params: { :type => "interactive", :id_or_filter_value => interactive.id }
        expect(response).to redirect_to stem_resources_url(interactive.external_activity_id, activity.name.parameterize)
        get :show, params: { :type => "interactive", :id_or_filter_value => interactive.id, :slug => "test" }
        expect(response).to redirect_to stem_resources_url(interactive.external_activity_id, activity.name.parameterize)
      end
  
      it "should return 404 when an unknown interactive is used" do
        get :show, params: { :type => "interactive", :id_or_filter_value => 999999999999999 }
        expect(response).not_to be_successful
        get :show, params: { :type => "interactive", :id_or_filter_value => 999999999999999, :slug => "test" }
        expect(response).not_to be_successful
      end
  
      #
      # This should fall through to the home page as a search filter.
      #
      xit "should return 200 when an unknown type is used" do
        get :show, params: { :type => "unknown-type", :id_or_filter_value => 1 }
        expect(response).to be_successful
        get :show, params: { :type => "unknown-type", :id_or_filter_value => 1, :slug => "test" }
        expect(response).to be_successful
      end
  
      xit "should set the start of the page title to the resource name" do
        get :show, params: { :id => activity.id }
        puts @response.inspect
        expect(response.body).to include("<title>#{activity.name}")
      end
    end
end
