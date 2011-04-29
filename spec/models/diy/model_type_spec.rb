require 'spec_helper'

describe Diy::ModelType do

  def make(attribs)
    Diy::ModelType.create(attribs)
  end
  before(:each) do
    @valid_attributes = {
      :name => "first modle_Type",
      :description => "a description",
      :otrunk_object_class => "OTThingy",
      :otrunk_view_class => "OTThingyView",
      :diy_id => 5
    }
  end

  it "should create a new instance given valid attributes" do
    make(@valid_attributes).errors.should be_empty
  end

  describe "enforcing field validations" do
    validating_fields = %w[ diy_id name otrunk_object_class otrunk_view_class].map {|e| e.to_sym }
    validating_fields.each do |field|
      it "should not create instances with bad #{field.to_s.humanize.pluralize}" do
        test_case = make(@valid_attributes.update(field => nil))
        test_case.should have(1).errors_on(field)
      end
    end
  end
  
  describe "importing objects from itisisu-diy portal" do
    before(:each) do
      @itsi_model_type = mock_model(Itsi::ModelType,
          :name => "itsi model type",
          :description => "itsi model type desc.",
          :id => 3,
          :url => "http://netologo.org/",
          :otrunk_object_class => "OTFakeType",
          :otrunk_view_class => "OTFakeTypeView",
          :authorable => true,
          :sizeable => true,
          :valid => true,
          :attributes => {
            "name" => "itsi model type",
            "description" => "itsi model type desc.",
            "id" => 3,
            "url" => "http://netologo.org/",
            "otrunk_object_class" => "OTFakeType",
            "otrunk_view_class" => "OTFakeTypeView",
            "authorable" => true,
            "sizeable" => true,
          }
      )
    end

    it "should create a valid copy of an itsi_model" do
      test_case = Diy::ModelType.from_external_portal(@itsi_model_type)
      test_case.should_not be_nil
      test_case.should be_valid
    end
  end
end

