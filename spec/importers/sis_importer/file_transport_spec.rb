describe SisImporter::FileTransport do

  before(:each) do
    @opts = {
        :district   => 'Boston',
        :output_dir => File.join('sis_import_data','test'),
        :csv_files  => %w[one two three]
    }
    @file_transport = SisImporter::FileTransport.new(@opts)
  end

  describe "defaults" do
    it "should include csv_files" do
      @file_transport.defaults[:csv_files].should_not be_nil
    end
    it "should include output_dir" do
      @file_transport.defaults[:output_dir].should_not be_nil
    end
    it "should include a district" do
      @file_transport.defaults[:district].should_not be_nil
    end
  end

  describe "set_option(key,value)" do
    it "should save options" do
      @file_transport.set_option(:a, :b)
      @file_transport.options(:a).should == :b
    end
  end

  describe "set_options(opts)" do
    it "should call set_option for each option" do
      @opts.keys.each do | key |
        @file_transport.should_receive(:set_option).once.with(key, @opts[key])
      end
      @file_transport.set_options(@opts)
    end
  end
  
  describe "output_dir" do
    it "should be the output directory specified in the options" do
      @file_transport.output_dir.should == @opts[:output_dir]
    end
  end

  describe "local_path(file)" do
    it "should be the the path 'output_dir/filename'" do
      @file_transport.local_path("foo").should == "sis_import_data/test/foo"
    end
  end

  describe "local_district_path" do
    it "should be the path 'output_dir/<district>/<timestamp>'" do
      fake_time = "201109231234"
      output_dir = @opts[:output_dir]
      fake_district = @opts[:district] #"Boston"
      @file_transport.should_receive(:timestamp).and_return(fake_time)
      @file_transport.local_district_path.should == [output_dir,fake_district,fake_time].join("/")
    end
  end

  describe "local_current_district_path" do
    it "should be the path 'output_dir/<district>/current'" do
      output_dir = @opts[:output_dir]
      fake_district = @opts[:district] #"Boston"
      @file_transport.local_current_district_path.should == [output_dir,fake_district,"current"].join("/")
    end
  end

  describe "relink_local_current_district_path" do
    before(:each) do
      FileUtils.stub!(:rm_f)
      FileUtils.stub!(:ln_s)
      @current_dir    = "current"
      @timestamp_dir  = "timestamp"
      @file_transport.stub!(:local_current_district_path => @current_dir)
      @file_transport.stub!(:local_district_path => @timestamp_dir)
    end
    it "should remove the old current symlink" do
      FileUtils.should_receive(:rm_f).with(@current_dir) 
      @file_transport.relink_local_current_district_path
    end
    it "should link the timestamp folder to the new folder" do
      FileUtils.should_receive(:ln_s).once.with(@timestamp_dir,@current_dir,:force=>true)
      @file_transport.relink_local_current_district_path
    end
  end

  describe "get_csv_files" do
    it "should call get_csv_file with each file" do
      @opts[:csv_files].each do |file|
        @file_transport.should_receive(:get_csv_file).once.with("#{file}.csv")
      end
      @file_transport.get_csv_files
    end
  end

  describe "logger" do
    it "should have a default logger" do
      @file_transport.logger.should_not be_nil
    end
    describe "with a custom logger" do
      before(:each) do
        @logger = mock("logger")
        @file_transport.set_option(:logger, @logger)
      end
      it "should return the custom logger" do
        @file_transport.logger.should == @logger
      end
    end
  end

  describe "error(message, exc, tags=[])" do
    it "should keep track of untagged errors" do
      error = SisImporter::Errors::Error.new('Gah!');
      @file_transport.error(error)
      @file_transport.errors.should include(error)
    end
  end

end
