require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::RawOtmlsController do

  it_should_behave_like 'an embeddable controller'

  def mock_otrunk_import
    if @mock_otrunk_import
      @mock_otrunk_import
    else
      @mock_otrunk_import = mock_model(OtrunkExample::OtrunkImport,
        :classname => "OTDataAxis",
        :fq_classname => "org.concord.datagraph.state.OTDataAxis")
    end
  end

  before(:each) do
    Embeddable::RawOtml.stub!(:otrunk_imports).and_return(["org.concord.datagraph.state.OTDataAxis"])
  end

  def with_tags_like_an_otml_raw_otml
    assert_select('OTCompoundDoc')
  end

end
