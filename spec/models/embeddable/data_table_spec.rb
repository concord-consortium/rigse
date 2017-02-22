require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::DataTable do
  before(:each) do
    @table = Embeddable::DataTable.create
  end

  describe "object creation" do
    it "should create a new instance given valid attributes" do
      expect(@table).to be_valid
    end

    it "should use the following default values" do
      expect(@table.column_count).to eq(3)
      expect(@table.visible_rows).to eq(9)
      expect(@table.precision).to eq(2)
      expect(@table.width).to eq(1200)
      expect(@table.is_numeric).to eq(true)
    end
  end

  describe "object serialization" do

    it "should serialize headings" do
      @table.headings=["one","two","three"]
      @table.save
      @table.reload
      expect(@table.headings[0]).to eq("one")
      expect(@table.heading(1)).to eq("one")
    end
  
    it "should serialize data" do
      @table.data=["1","2","3"]
      @table.save
      @table.reload
      expect(@table.data[0]).to eq("1")
      expect(@table.cell_data(1,1)).to eq("1")
    end
  end

end
