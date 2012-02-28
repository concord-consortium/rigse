require File.expand_path('../../../spec_helper', __FILE__)
describe SisImporter::Configuration do

  before(:each) do
    @opts = {
        :district   => 'Boston',
        :output_dir => File.join('sis_import_data','test'),
        :csv_files  => %w[one two three]
    }
    @configuration = SisImporter::Configuration.new(@opts)
  end
  describe "defaults" do
    it "should include csv_files" do
      @configuration.defaults[:csv_files].should_not be_nil
    end
    it "should include a district" do
      @configuration.defaults[:district].should_not be_nil
    end
  end

  # describe "set_option(key,value)" do
  #   it "should save options" do
  #     @configuration.set_option(:a, :b)
  #     @configuration.options(:a).should == :b
  #   end
  # end

  # describe "set_options(opts)" do
  #   it "should call set_option for each option" do
  #     @opts.keys.each do | key |
  #       @configuration.should_receive(:set_option).once.with(key, @opts[key])
  #     end
  #     @configuration.set_options(@opts)
  #   end
  # end
  
  # describe "logger" do
  #   it "should have a default logger" do
  #     @configuration.logger.should_not be_nil
  #   end
  #   describe "with a custom logger" do
  #     before(:each) do
  #       @logger = mock("logger")
  #       @configuration.set_option(:logger, @logger)
  #     end
  #     it "should return the custom logger" do
  #       @configuration.logger.should == @logger
  #     end
  #   end
  # end
end
