require 'spec_helper'

describe NotificationsController do

  before(:each) do
    OpenURI.stub!(:open_uri).and_return('{"results":[], "last_seq":1}')
  end

  it "should accept assessment update notifications" do
    route_for(:controller => 'notifications', :action => 'assessments', :method => :get).should == "/notifications/assessments"
    get :assessments
  end

  it 'should fire off the assessments learner data importer' do
    couch = "http://localhost/db/assessments"
    @mock_importer = mock(Assessments::LearnerDataImporter, :run => true)
    Assessments::LearnerDataImporter.should_receive(:new).and_return(@mock_importer)
    get :assessments, :db => couch
  end
end
