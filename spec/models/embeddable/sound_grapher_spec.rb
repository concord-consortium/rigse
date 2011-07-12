require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::SoundGrapher do
  before(:each) do
    @valid_attributes = {
      :display_mode    => "Waves",
      :max_sample_time => "30",
      :max_frequency   => "1000",
    }
  end

  describe "object creation" do
    it "should create a new instance given valid attributes" do
      new_graph = Embeddable::SoundGrapher.create(@valid_attributes)
      new_graph.should be_valid
    end

    it "should create a new instance with valid defaults" do
      new_graph = Embeddable::SoundGrapher.create
      new_graph.should be_valid
    end

    it "should have validation errors when created with bad attributes" do
      new_graph = Embeddable::SoundGrapher.create(@valid_attributes.merge(:max_frequency   => "40"))
      new_graph.should_not be_valid
      new_graph = Embeddable::SoundGrapher.create(@valid_attributes.merge(:max_sample_time => "4"))
      new_graph.should_not be_valid
      new_graph = Embeddable::SoundGrapher.create(@valid_attributes.merge(:display_mode    => "Plaid"))
      new_graph.should_not be_valid
    end
  end

end
