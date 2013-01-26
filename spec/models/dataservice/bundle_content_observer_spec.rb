require File.expand_path('../../../spec_helper', __FILE__)

describe Dataservice::BundleContentObserver do
  it "should run delayed process job" do 
      @bc = mock_model(Dataservice::BundleContent)
      @obs = Dataservice::BundleContentObserver.instance
      @bc.should_receive(:otml_empty?).and_return(false)
      Dataservice::BundleContent.should_receive(:find).and_return(@bc)
      @bc.should_receive(:delayed_process_bundle)
      @obs.after_save(@bc)
  end
end