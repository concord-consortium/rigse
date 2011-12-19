require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::LabBookSnapshot do

  # TODO: I am not happy with how flakey send_updates_to is
  # It took a while to finagle this test. It should probably be
  # looked at closer.
  it "should send updates to investigations when changed" do
    investigation = mock("investigation")
    investigations = [investigation]
    snapshot = Embeddable::LabBookSnapshot.new(:name => "button", :target_element_type => "fake", :target_element_id => 3)
    
    snapshot.should_receive(:save)
    snapshot.should_receive(:investigations).and_return(investigations)
    investigation.should_receive(:update_attribute).and_return(true)
    snapshot.update_attributes({:name => "button changed"})
    snapshot.destroy
  end
  
end
