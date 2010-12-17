shared_examples_for 'a cloneable model' do
  embeddable_class_lambda = lambda { self.send(:described_class) }

  before(:each) do
    @embeddable_class = embeddable_class_lambda.call
  end

  describe "cloneable specification" do
    it "should have a class method named cloneable_associations" do
      @embeddable_class.should respond_to :cloneable_associations
    end
    it "should not define @@cloneable_associations" do
      @embeddable_class.class_variables.should_not include("@@cloneable_associations")
    end
  end
end
