require 'spec_helper'

describe Browse::ActivitiesController do
    before(:each) do
        @controller = Browse::ActivitiesController.new
        @request = ActionController::TestRequest.new
        @response = ActionController::TestResponse.new
        @author_user = Factory.next(:author_user)
        @physics_investigation = Factory.create(:investigation, :name => 'physics_inv', :user => @author_user, :publication_status => 'published')
        @laws_of_motion_activity = Factory.create(:activity, :name => 'laws_of_motion_activity' ,:investigation_id => @physics_investigation.id, :user => @author_user)
    end
    
    describe "GET show" do
      it "should preview activity details" do
         @post_params = {
          :search_term => @laws_of_motion_activity.name,
          :investigation_page=>1,
          :activity_page=>1,
          :type=>"act",
          :id=>@laws_of_motion_activity.id
        }
        post :show,@post_params
        assert_equal assigns[:back_url],"#{request.url}search?activity_page=1&investigation_page=1&search_term=#{@laws_of_motion_activity.name}&type=act"
        assert_equal assigns[:material], @laws_of_motion_activity
        assert_equal assigns[:wide_content_layout],true
      end
    end

end