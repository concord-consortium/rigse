shared_examples_for 'a saveable' do
  
  model_class_lambda = lambda { self.send(:described_class) } 
  model_name_lambda  = lambda { model_class_lambda.call.name.underscore_module }

  def create_new(model_name)
    method_name = "create_new_#{model_name}".to_sym
    if self.respond_to?(method_name)
      return self.send(method_name)
    else
      return Factory.create(model_name)
    end
  end

  before(:each) do
    @model_class = model_class_lambda.call
    @model_ivar = create_new(model_name_lambda.call)
  end
  
  describe "belong to an embeddable and" do
    it "respond to embeddable?" do
      @model_ivar.should respond_to :embeddable
    end
    it "return an embeddable instance" do
      @model_ivar.embeddable.should_not be_nil
    end
  end
end
