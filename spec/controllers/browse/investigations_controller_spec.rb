require 'spec_helper'

describe Browse::InvestigationsController do
    before(:each) do
        @controller = Browse::InvestigationsController.new
        @request = ActionController::TestRequest.new
        @response = ActionController::TestResponse.new
        @author_user = Factory.next(:author_user)
        @physics_investigation = Factory.create(:investigation, :name => 'physics_inv', :user => @author_user, :publication_status => 'published')
    end
    
    describe "GET show" do
      it "should preview investigation details" do
         @post_params = {
          :search_term => @physics_investigation.name,
          :investigation_page=>1,
          :activity_page=>1,
          :type=>"inv",
          :id=>@physics_investigation.id
        }
        post :show,@post_params
        assert_equal assigns[:back_url],"#{request.url}search?activity_page=1&investigation_page=1&search_term=#{@physics_investigation.name}&type=inv"
        assert_equal assigns[:material], @physics_investigation
        assert_equal assigns[:wide_content_layout],true
      end
    end

end