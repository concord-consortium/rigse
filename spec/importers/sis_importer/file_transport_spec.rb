require File.expand_path('../../../spec_helper', __FILE__)
describe SisImporter::FileTransport do

  before(:each) do
    @opts = {
        :district   => 'Boston',
        :local_root_dir => File.join('sis_import_data','test'),
        :csv_files  => %w[one two three]
    }
    @file_transport = SisImporter::FileTransport.new(SisImporter::Configuration.new(@opts))
  end

  
  describe "local_root_dir" do
    it "should be the output directory specified in the options" do
      @file_transport.configuration.local_root_dir.should == @opts[:local_root_dir]
    end
  end

  describe "local_path(file)" do
    it "should be the the path 'local_root_dir/filename'" do
      @file_transport.local_path("foo").should == "sis_import_data/test/foo"
    end
  end

  describe "local_district_path" do
    it "should be the path 'local_root_dir/<district>/<timestamp>'" do
      fake_time = "201109231234"
      local_root_dir = @opts[:local_root_dir]
      fake_district = @opts[:district] #"Boston"
      @file_transport.should_receive(:timestamp).and_return(fake_time)
      @file_transport.local_district_path.should == [local_root_dir,fake_district,fake_time].join("/")
    end
  end

  describe "local_current_district_path" do
    it "should be the path 'local_root_dir/<district>/current'" do
      local_root_dir = @opts[:local_root_dir]
      fake_district = @opts[:district] #"Boston"
      @file_transport.local_current_district_path.should == [local_root_dir,fake_district,"current"].join("/")
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


  describe "error(message, exc, tags=[])" do
    it "should keep track of untagged errors" do
      error = SisImporter::Errors::Error.new('Gah!');
      @file_transport.error(error)
      @file_transport.errors.should include(error)
    end
  end

end
