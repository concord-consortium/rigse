require 'spec_helper'

describe Embeddable::Diy::SectionsController do
  integrate_views

  describe "PUT update" do
    it 'handles xhr update' do
      section = Factory.build :diy_section
      section.should_receive(:update_attributes).and_return(true)
      Embeddable::Diy::Section.stub!(:find).with("1").and_return(section)
      xhr :put, :update, :id => 1
    end
  end
end