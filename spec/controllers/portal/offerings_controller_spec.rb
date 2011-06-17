require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::OfferingsController do
  before(:each) do
    generate_default_project_and_jnlps_with_mocks
    generate_portal_resources_with_mocks
    Admin::Project.stub!(:default_project).and_return(@mock_project)
  end

  it "saves learner data in the cookie" do
    # this seems like it would all be better with some factories for clazz, runnable, offering, and learner
    clazz = mock_model(Portal::Clazz)
    runnable = mock_model(ExternalActivity, :name      => "Some Activity",
                                            :url       => "http://example.com",
                                            :save_path => "/path/to/save")
    offering = mock_model(Portal::Offering, :runnable => runnable, :clazz => clazz)
    @user = Factory(:user, :email => "test@test.com", :password => "password", :password_confirmation => "password")
    portal_student = mock_model(Portal::Student)
    learner = mock_model(Portal::Learner, :offering => offering, :student => portal_student)
    controller.stub!(:setup_portal_student).and_return(learner)
    Portal::Offering.stub!(:find).and_return(offering)
    stub_current_user :user

    get :show, :id => offering.id, :format => 'run_external_html'
    response.cookies["save_path"].should == offering.runnable.save_path
    response.cookies["learner_id"].should == learner.id.to_s
    response.cookies["student_name"].should == "#{current_user.first_name} #{current_user.last_name}"
    response.cookies["activity_name"].should == offering.runnable.name
    response.cookies["class_id"].should == clazz.id.to_s
  end
end
