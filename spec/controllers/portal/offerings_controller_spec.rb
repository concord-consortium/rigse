require 'spec_helper'

describe Portal::OfferingsController do
  before(:each) do
    generate_default_project_and_jnlps_with_mocks
    generate_portal_resources_with_mocks
    Admin::Project.should_receive(:default_project).and_return(@mock_project)
  end

  it "saves learner data in the cookie" do
    offering = mock_model(Portal::Offering)
    Portal::Offering.stub!(:find).and_return(offering)
    runnable = mock_model(ExternalActivity, :name      => "Some Activity",
                                            :url       => "http://example.com",
                                            :save_path => "/path/to/save")
    @user = Factory(:user, :email => "test@test.com", :password => "password", :password_confirmation => "password")
    offering.stub!(:runnable).and_return(runnable)
    offering.stub!(:find_or_create_learner).and_return(@user)
    portal_student = mock_model(Portal::Student)
    @user.stub!(:portal_teacher)
    @user.stub!(:portal_student).and_return(portal_student)
    stub_current_user :user

    get :show, :id => offering.id, :format => 'run_external_html'
    response.cookies["save_path"].should == offering.runnable.save_path
    response.cookies["learner_id"].should == @user.id.to_s
    response.cookies["student_name"].should == "#{current_user.first_name} #{current_user.last_name}"
    response.cookies["activity_name"].should == offering.runnable.name
    #response.cookies[:class_id]
  end
end
