require File.expand_path('../../../spec_helper', __FILE__)

class FakeFTP
  attr_accessor :data
  def initialize(_data)
    self.data = _data
  end
  def download!(remote,local)
    File.open(local,'w') do |file|
      file.write(self.data)
    end
  end
end

describe SisImporter::RemoteConfiguration do
  before(:each) do
    @username="username"
    @password="password"
    @host="host"
    @remote_config  = SisImporter::RemoteConfiguration.new({
      :username => @username,
      :password => @password,
      :host     => @host
    });
  end

  describe "without connection errors" do
    before(:each) do
      @data = "  disricta \n  districtb   \n districtc \n\n"
      @ftp = FakeFTP.new(@data)
      Net::SFTP.stub!(:start).and_yield(@ftp)
      @ftp.stub!(:stat!).and_return(true)
      @expected = ['disricta','districtb','districtc']
    end

    describe "districts" do
      it "should return expected districts" do
        # @remote_config.should_receive(:in_progress?).and_return(false)
        # @remote_config.should_receive(:remove_old_signals)
        # @remote_config.should_receive(:signal_in_progress)
        @remote_config.districts.should eql @expected
      end
    end

  end

  describe "with connection errors" do
    before(:each) do
      # @remote_config.stub!(:in_progress?).and_return(false)
      # @remote_config.stub!(:remove_old_signals)
      # @remote_config.stub!(:signal_in_progress)
      Net::SFTP.stub!(:start).and_raise(NoMethodError.new("undefined method `shutdown!' for nil:NilClass"))
    end

    describe "districts" do
      it "should throw an exception" do
        # probably should think about this some more..
        lambda { @remote_config.districts }.should raise_error(SisImporter::Errors::ConnectionError)
      end
    end
  end
end

