require 'spec_helper'

describe Diy::Model do
  before(:each) do
 
    def make(attributes)
      Diy::Model.create(attributes)
    end
    @valid_model_type = mock_model(Diy::ModelType, 
      :id => 220,
      :diy_id => 1,
      :name => "test model type",
      :description => "test model type",
      :otrunk_object_class => "OTNLogo",
      :otrunk_view_class => "OTNLogoView")
    @valid_attributes = {
      :name => "model",
      :description => "a description of a model",
      :model_type => @valid_model_type,
      :diy_id => 2
    }
  end

  it "should create a new instance given valid attributes" do
    test_case = make(@valid_attributes)
    test_case.should be_valid
    test_case.should have(0).errors_on(:diy_id)
  end
  
  describe "enforcing field validations" do
    validating_fields = %w[ diy_id model_type name ].map {|e| e.to_sym }
    validating_fields.each do |field|
      it "should not create instances with bad #{field.to_s.humanize.pluralize}" do
        test_case = make(@valid_attributes.update(field => nil))
        test_case.should have(1).errors_on(field)
      end
    end
  end
  
  it "should deligate otrunk_object_class and otrunk_view_class to model_type" do
    test_case = make(@valid_attributes)
    test_case.should be_valid
    [:otrunk_object_class, :otrunk_view_class].each do |method|
      @valid_model_type.should respond_to method
      test_case.should respond_to method
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
            "id"=> 3,
            "url" => "http://netologo.org/",
            "otrunk_object_class" => "OTFakeType",
            "otrunk_view_class" => "OTFakeTypeView",
            "authorable" => true,
            "sizeable" => true,
          }
      )
      @itsi_model = mock_model(Itsi::Model,
          :name => "fake model",
          :model_type => @itsi_model_type,
          :url => @itsi_model_type.url,
          :id => 33,
          :attributes => {
            "name" => "fake model",
            "model_type" => @itsi_model_type,
            "url" => @itsi_model_type.url,
            "id" => 33,
          }
      )  
    end

    it "should create a valid copy of an itsi_model" do
      test_case = Diy::Model.from_external_portal(@itsi_model)
      test_case.should_not be_nil
      test_case.should be_valid
    end
  end

end
