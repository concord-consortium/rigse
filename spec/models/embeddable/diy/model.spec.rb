require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Embeddable::Diy::Model do
  def create(attributes)
    Embeddable::Diy::Model.create(attributes)
  end

  before(:each) do
    @model_type = mock_model(Diy::ModelType
      :diy_id => 1,
      :otrunk_object_class = "OTClass",
      :otrunk_view_class = "OTView",
    )
    @model = mock_model(Diy::Model,
        :model_type => @model_type,
        :name => "name",
        :description => "description",
        :url => "url")

    @valid_attributes={
      :user => @user,
      :model => @model
    }
  end

  describe "field validations" do
    it "should create a new instance given valid attributes" do
      test_case = create(@valid_attributes)
      test_case.should be_valid
    end
  end

end
