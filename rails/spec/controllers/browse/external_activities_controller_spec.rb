require 'spec_helper'

describe Browse::ExternalActivitiesController do
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
        post :show, @post_params

        expect(assigns[:wide_content_layout]).to eq(true)

        expect(assigns[:back_to_search_url]).to match /.*search\?activity_page=1&investigation_page=1&search_term=#{@external_activity.name}$/
        expect(assigns[:search_material]).not_to be_nil
        expect(assigns[:search_material].material).to eq(@external_activity)
      end
    end
end
