require File.expand_path('../../spec_helper', __FILE__)

def valid_yaml
return <<YAML
---
default :
  String : this is a String
  local_only: in default
my_theme:
  Hash : this is a Hash
  someString : a string replacement
  local_only: in my_theme
  a::key::with::modules: even works with keys with ::'s
YAML
end

def invalid_yaml
  return "gobbledy guck"
end

describe LocalNames do
  before(:each) do
    @instance = LocalNames.instance('my_theme')
    @logger = mock("Logger")
    @instance.logger=@logger
    @mock_file = mock("File")
  end
  describe "Loading local names from a file config/local_names.yml" do
    describe "When the config file is missing" do
      before(:each) do
        File.stub!(:open).and_raise(Errno::ENOENT)
      end
      it "should not cause an error, but should report a warning" do
        @logger.should_receive(:warn)
        @instance.load_names
      end
    end

    describe "When the local names file is invalid" do
      before(:each) do
        File.stub!(:open).and_return(@mock_file)
      end
      it "should not cause an error, but should produce a warning message" do
        @mock_file.should_receive(:read).and_return(invalid_yaml)
        # once for the default theme..
        @logger.should_receive(:warn).twice
        @instance.load_names
      end
    end
  end 
  
  describe "Looking up local names" do
    before(:each) do
      File.stub!(:open).and_return(@mock_file)
      @mock_file.should_receive(:read).and_return(valid_yaml)
      @instance.load_names
    end
    it "should have local names" do
      @instance.local_names.should_not be_nil
    end
    describe "Asking for local names" do
      describe "When a local replacement has been defined" do
        it "should use the replacement for an instance" do
          @instance.local_name_for({}).should == "this is a Hash"
          @instance.local_name_for("someString").should == "a string replacement"
        end
        it "should use the plreacement for the class" do
          @instance.local_name_for(Hash).should == "this is a Hash"
          @instance.local_name_for(String).should == "this is a String"
        end
      end
      describe "When a local replacement has been defined" do
        it "should use the replacement" do
          @instance.local_name_for({}).should == "this is a Hash"
          @instance.local_name_for("someString").should == "a string replacement"
        end
      end
      describe "When a theme overrides a default value" do
        it "should use the theme's" do
          @instance.local_name_for("local_only").should == "in my_theme"
        end
      end
      describe "When the key name includes :: module separators" do
        it "should still work" do
          @instance.local_name_for("a::key::with::modules").should == "even works with keys with ::'s"
        end
      end
      describe "When no local replacement has been defined" do
        describe "When the caller specifies a default value" do  
          it "should use the default replacement value" do
            @instance.local_name_for(self,"default").should == "default"
          end
        end
        describe "When the caller doesn't specify a default" do
          it "should use the titlecased human readable class name" do
            @instance.local_name_for(@instance).should == "Local Names"
          end
        end
      end
    end
  end

end
