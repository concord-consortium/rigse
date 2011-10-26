require File.expand_path('../../spec_helper', __FILE__)

describe "String#underscore_module" do

  it "should replace '::' with '_'" do
    "Activity".underscore_module.should eql('activity')
    "Embeddable::DataCollector".underscore_module.should eql('embeddable_data_collector')
    "Embeddable::Smartgraph::RangeQuestion" .underscore_module.should eql('embeddable_smartgraph_range_question')
  end

  it "should replace '/' with '_'" do
    "activity".underscore_module.should eql('activity')
    "embeddable/data_collector".underscore_module.should eql('embeddable_data_collector')
    "embeddable/smartgraph/range_question" .underscore_module.should eql('embeddable_smartgraph_range_question')
  end
  
end

describe "String#delete_module" do

  it "should remove one module delimited with '::' from the beginning of the string" do
    "Activity".delete_module.should eql('Activity')
    "Embeddable::DataCollector".delete_module.should eql('DataCollector')
    "Embeddable::Smartgraph::RangeQuestion".delete_module.should eql('Smartgraph::RangeQuestion')
  end
  
  it "should remove one module delimited with '/' from the beginning of the string" do
    "activity".delete_module.should eql('activity')
    "embeddable/data_collector".delete_module.should eql('data_collector')
    "embeddable/smartgraph/range_question".delete_module.should eql('smartgraph/range_question')
  end

  it "should remove more modules delimited with '::' from the beginning of the string when a numerical argument is passed" do
    "Activity".delete_module(2).should eql('Activity')
    "Embeddable::DataCollector".delete_module(2).should eql('DataCollector')
    "Embeddable::Smartgraph::RangeQuestion".delete_module(2).should eql('RangeQuestion')
  end
  
  it "should optionally remove more modules delimited with '/' from the beginning of the string when a numerical argument is passed" do
    "activity".delete_module(2).should eql('activity')
    "embeddable/data_collector".delete_module(2).should eql('data_collector')
    "embeddable/smartgraph/range_question".delete_module(2).should eql('range_question')
  end
end
