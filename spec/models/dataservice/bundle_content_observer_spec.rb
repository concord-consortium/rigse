require File.expand_path('../../../spec_helper', __FILE__)

describe Dataservice::BundleContentObserver do
  it "should fire off async methods" do 
      @bc = mock_model(Dataservice::BundleContent)
      @obs = Dataservice::BundleContentObserver.instance
      @bc.should_receive(:extract_saveables)
      @bc.should_receive(:copy_to_collaborators)
      @obs.after_save(@bc)
  end
end