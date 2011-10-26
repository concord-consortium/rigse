require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::DataTable do
  before(:each) do
    @table = Embeddable::DataTable.create
  end

  describe "object creation" do
    it "should create a new instance given valid attributes" do
      @table.should be_valid
    end

    it "should use the following default values" do
      @table.column_count.should == 3
      @table.visible_rows.should == 9
      @table.precision.should == 2
      @table.width.should == 1200
      @table.is_numeric.should == true
    end
  end

  describe "object serialization" do

    it "should serialize headings" do
      @table.headings=["one","two","three"]
      @table.save
      @table.reload
      @table.headings[0].should == "one"
      @table.heading(1).should == "one"
    end
  
    it "should serialize data" do
      @table.data=["1","2","3"]
      @table.save
      @table.reload
      @table.data[0].should == "1"
      @table.cell_data(1,1).should == "1"
    end
  end

end
