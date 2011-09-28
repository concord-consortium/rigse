describe SisImporter::Errors::Error do

end




describe SisImporter::Errors::Collector do

  describe "collection_for(thing)" do
    it "should keep a unique collection for every instance" do
      a = Object.new
      b = Object.new
      SisImporter::Errors::Collector.collection_for(a).should_not equal SisImporter::Errors::Collector.collection_for(b)
      SisImporter::Errors::Collector.collection_for(a).should equal SisImporter::Errors::Collector.collection_for(a)
      collection = SisImporter::Errors::Collector.instance_variable_get(:@collections)
      collection[a].should_not be_nil
      collection[a].should_not be_nil
    end
  end


  describe  "errors(tag=:all)" do
    before(:each) do
      @thing = Object.new
      @thing.extend SisImporter::Errors::Collector
    end

    describe "with no tag specified" do
      it "should return all errors in the collection" do
        @all = ['aerror','berror']
        @original_errors = {:all => @all}
        SisImporter::Errors::Collector.stub!(:collection_for => @original_errors)
        @thing.errors.should eql @all
      end
    end

    describe "with the tag name :foo" do
      it "should return errors tagged with :foo" do
        @fooErrors = ['foo_a','foo_b']
        @otherErrors = ['aerror','berror']
        @original_errors = {:all => @otherErrors + @fooErrors, :foo => @fooErrors}
        SisImporter::Errors::Collector.stub!(:collection_for => @original_errors)
        @thing.errors(:foo).should eql @fooErrors
      end
    end

  end

  describe "error(message, exc=$!, tags=[])" do
    before(:each) do
      @collector = Object.new
      @collector.extend SisImporter::Errors::Collector
      @logger = mock("logger")
      @logger.stub!(:error)
      @collector.stub!(:logger => @logger)
      @message = "Bang!"
      @original_error = StandardError.new("foo")
      @sis_error = SisImporter::Errors::Error.new(@message,@original_error)
    end

    it "should log the errors message" do
      @logger.should_receive(:error).with(@sis_error.message)
      @collector.error(@sis_error)
    end

    it "should collect the error with a tag" do
      @collector.error(@sis_error, [:foo])
      @collector.errors(:foo).should_not be_nil
      @collector.errors(:foo).first.should eql @sis_error
      @collector.errors(:foo).first.original.should eql @original_error
    end

    it "should collect the error into the :all tag" do
      @collector.error(@sis_error, [:foo])
      @collector.errors.should_not be_nil
      @collector.errors.first.should eql @sis_error
      @collector.errors.first.original.should eql @original_error
    end

    it "should raise the error if the Error is fatal" do
      @sis_error = SisImporter::Errors::FatalError.new(@message,@original_error)
      lambda {
        @collector.error(@sis_error)
      }.should raise_exception
    end
  end

end

