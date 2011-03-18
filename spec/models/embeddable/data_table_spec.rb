require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Embeddable::DataTable do

  it "should create a new instance given valid attributes" do
    data_table = Embeddable::DataTable.new
    data_table.save 
    data_table.data_collector.should be_nil
    data_table.should be_valid
  end
end
