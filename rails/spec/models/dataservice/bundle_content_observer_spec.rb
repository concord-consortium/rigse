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


  # TODO: auto-generated
  describe '#after_create' do
    xit 'after_create' do
      bundle_content_observer = described_class.new
      bundle_content = double('bundle_content')
      result = bundle_content_observer.after_create(bundle_content)

      expect(result).not_to be_nil
    end
  end
end
