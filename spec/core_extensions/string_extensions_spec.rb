require File.expand_path('../../spec_helper', __FILE__)

describe "String#underscore_module" do

  it "should replace '::' with '_'" do
    expect("Activity".underscore_module).to eql('activity')
    expect("Embeddable::DataCollector".underscore_module).to eql('embeddable_data_collector')
    expect("Embeddable::Smartgraph::RangeQuestion" .underscore_module).to eql('embeddable_smartgraph_range_question')
  end

  it "should replace '/' with '_'" do
    expect("activity".underscore_module).to eql('activity')
    expect("embeddable/data_collector".underscore_module).to eql('embeddable_data_collector')
    expect("embeddable/smartgraph/range_question" .underscore_module).to eql('embeddable_smartgraph_range_question')
  end
  
end

describe "String#delete_module" do

  it "should remove one module delimited with '::' from the beginning of the string" do
    expect("Activity".delete_module).to eql('Activity')
    expect("Embeddable::DataCollector".delete_module).to eql('DataCollector')
    expect("Embeddable::Smartgraph::RangeQuestion".delete_module).to eql('Smartgraph::RangeQuestion')
  end
  
  it "should remove one module delimited with '/' from the beginning of the string" do
    expect("activity".delete_module).to eql('activity')
    expect("embeddable/data_collector".delete_module).to eql('data_collector')
    expect("embeddable/smartgraph/range_question".delete_module).to eql('smartgraph/range_question')
  end

  it "should remove more modules delimited with '::' from the beginning of the string when a numerical argument is passed" do
    expect("Activity".delete_module(2)).to eql('Activity')
    expect("Embeddable::DataCollector".delete_module(2)).to eql('DataCollector')
    expect("Embeddable::Smartgraph::RangeQuestion".delete_module(2)).to eql('RangeQuestion')
  end
  
  it "should optionally remove more modules delimited with '/' from the beginning of the string when a numerical argument is passed" do
    expect("activity".delete_module(2)).to eql('activity')
    expect("embeddable/data_collector".delete_module(2)).to eql('data_collector')
    expect("embeddable/smartgraph/range_question".delete_module(2)).to eql('range_question')
  end
end
