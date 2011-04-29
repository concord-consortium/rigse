require 'spec_helper'
describe Embeddable::Diy::EmbeddedModel do
  def create(attributes)
    Embeddable::Diy::EmbeddedModel.create(attributes)
  end

  before(:each) do
    @user = mock_model(User)
    @model_type = mock_model(Diy::ModelType,
      :diy_id  => 1,
      :name => "model type",
      :description => "description",
      :otrunk_object_class => "OTClass",
      :otrunk_view_class => "OTView"
    )
    @model = mock_model(Diy::Model,
        :model_type => @model_type,
        :name => "name",
        :description => "description",
        :url => "url")

    @valid_attributes={
      :user => @user,
      :diy_model => @model
    }
  end

  describe "field validations" do
    it "should create a new instance given valid attributes" do
      test_case = create(@valid_attributes)
      test_case.should be_valid
    end
  end
  
  describe "associations" do
    before(:each) do
      @model_type = Diy::ModelType.create(
        :diy_id  => 1,
        :name => "model type",
        :description => "description",
        :otrunk_object_class => "OTClass",
        :otrunk_view_class => "OTView"
      )
      @model = Diy::Model.create(
          :model_type => @model_type,
          :name => "name",
          :description => "description",
          :url => "url")
      @page = Page.create
      @embeddable = Embeddable::Diy::EmbeddedModel.create(
          :diy_model => @model)
    end
    it "belongs to a page" do
      
    end
    it "belongs to a model" do

    end

    it "should deligate methods" do
        @embeddable.diy_model.should_not be_nil
      %w[ name description url].map{ |e| e.to_sym}.each do |method|
        @embeddable.should respond_to method
        @embeddable.send(method).should == @model.send(method)
      end
    end
  end


end
