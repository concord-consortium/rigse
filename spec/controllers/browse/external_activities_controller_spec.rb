require 'spec_helper'

describe Browse::ExternalActivitiesController do
    before(:each) do
        @author_user = Factory.next(:author_user)
        @external_activity = Factory.create(:external_activity, :name => 'activity', :url => 'external.activity.org/1', :user => @author_user, :publication_status => 'published')
    end

    describe "GET show" do
      it "should preview external activity details" do
         @post_params = {
          :search_term => @external_activity.name,
          :investigation_page=>1,
          :activity_page=>1,
          :id=>@external_activity.id
        }
        post :show, @post_params

        assert_equal assigns[:wide_content_layout], true

        assigns[:back_url].should match /.*search\?activity_page=1&investigation_page=1&search_term=#{@external_activity.name}$/
        assert_not_nil assigns[:search_material]
        assert_equal assigns[:search_material].material, @external_activity
      end
    end

end