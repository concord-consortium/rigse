shared_examples_for 'an embeddable' do
  
  embeddable_class_lambda = lambda { self.send(:described_class) }
  model_ivar_name_lambda  = lambda { embeddable_class_lambda.call.name.delete_module.underscore_module }


  before(:each) do
    @embeddable_class = embeddable_class_lambda.call
    # what I want: if the caller has @valid_attributes use them.
    @valid_attributes ||= {} 
  end

  
  describe "enabling and disabling" do
    before(:each) do
      @test_case = @embeddable_class.create(@valid_attributes)
    end
    it "should respond to enable method" do
      @test_case.should respond_to :enable
    end
    it "should respond to diable method" do
      @test_case.should respond_to :disable
    end
    
    it "#enable should set is_enabled property to true the page_element" do
      page_element = mock_model(PageElement)
      @test_case.stub!(:page_elements => [page_element])
      page_element.should_receive(:is_enabled=).with(true)
      page_element.should_receive(:save)
      @test_case.enable
    end
    it "#disable should set is_enabled property to false of the page_element" do
      page_element = mock_model(PageElement)
      @test_case.stub!(:page_elements => [page_element])
      page_element.should_receive(:is_enabled=).with(false)
      page_element.should_receive(:save)
      @test_case.disable
    end
    it "#toggle_ennabled should appropriately modify the is_enabled property of all page_elements" do
      page_element_a = mock_model(PageElement)
      page_element_b = mock_model(PageElement)
      @test_case.stub!(:page_elements => [page_element_a,page_element_b])
      page_element_a.should_receive(:is_enabled).and_return(true)
      page_element_b.should_receive(:is_enabled).and_return(false)
      page_element_a.should_receive(:save)
      page_element_a.should_receive(:is_enabled=).with(false)
      page_element_b.should_receive(:save)
      page_element_b.should_receive(:is_enabled=).with(true)
      @test_case.toggle_enabled
    end

  end

end
