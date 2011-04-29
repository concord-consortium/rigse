require 'spec_helper'

describe Embeddable::Diy::EmbeddedModel do
  def create(attributes)
    Embeddable::Diy::EmbeddedModel.create(attributes)
  end

  before(:all) do
    @model_type = mock_model(Diy::ModelType,
      :diy_id => 1,
      :otrunk_object_class => "OTClass",
      :otrunk_view_class => "OTView"
    )
    @model = Diy::Model.create(
        :model_type => @model_type,
        :name => "name",
        :description => "description",
        :url => "http://wwww.concord.org/"
    )
  end
  before(:each) do
    @valid_attributes={
      :user => @user,
      :diy_model => @model
    }
  end
  
  it_should_behave_like 'an embeddable'

  describe "field validations" do
    it "should create a new instance given valid attributes" do
      test_case = create(@valid_attributes)
      test_case.should be_valid
    end
  end

  describe "delegating to the DIY model" do
    %w[ name description url otrunk_object_class otrunk_view_class].map{|e| e.to_sym}.each do |method|
      it "should respond to #{method.to_s} by deligating" do
        test_case = create(@valid_attributes)
        @model.should_receive(method).at_least(:once).and_return(method.to_s)
        test_case.should respond_to method
        test_case.send(method).should == @model.send(method)
      end
    end
  end

end
