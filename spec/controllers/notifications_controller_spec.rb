require 'spec_helper'

describe NotificationsController do
  it "should accept assessment update notifications" do
    route_for(:controller => 'notifications', :action => 'assessments', :method => :get).should == "/notifications/assessments"
    get :assessments
  end

  it 'should fire off the assessments learner data importer' do
    couch = "http://localhost/db/assessments"
    Bj.should_receive(:submit).with("::Assessments::LearnerDataImporter.new('#{couch}').run", {:tag => 'assessments_learner_data_import'})
    get :assessments, :db => couch
    response.should be_success
    response.should have_text "Import Scheduled"
  end
end
