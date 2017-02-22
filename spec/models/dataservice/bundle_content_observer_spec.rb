require File.expand_path('../../../spec_helper', __FILE__)

describe Dataservice::BundleContentObserver do
  it "should run delayed process job" do 
      @bc = mock_model(Dataservice::BundleContent)
      @obs = Dataservice::BundleContentObserver.instance
      expect(@bc).to receive(:otml_empty?).and_return(false)
      expect(Dataservice::BundleContent).to receive(:find).and_return(@bc)
      expect(@bc).to receive(:delayed_process_bundle)
      @obs.after_save(@bc)
  end
end