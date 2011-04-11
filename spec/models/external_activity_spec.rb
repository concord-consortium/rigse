require File.expand_path('../../spec_helper', __FILE__)

describe ExternalActivity do
  before(:each) do
    @valid_attributes = {
      :user_id => 1,
      :uuid => "value for uuid",
      :name => "value for name",
      :description => "value for description",
      :publication_status => "value for publication_status",
      :url => "http://www.concord.org/"
    }
  end

  it "should create a new instance given valid attributes" do
    ExternalActivity.create!(@valid_attributes)
  end

  describe "url transforms" do
    before(:each) do
      @act = ExternalActivity.create!(@valid_attributes)
      @learner = mock_model(Portal::Learner, :id => 34)
    end

    it "should default to not appending the learner id to the url" do
      @act.append_learner_id_to_url.should be_false
    end

    it "should return the original url when appending is false" do
      @act.url.should eql(@valid_attributes[:url])
      @act.url(@learner).should eql(@valid_attributes[:url])
    end

    it "should return a modified url when appending is true" do
      @act.append_learner_id_to_url = true
      @act.url.should eql(@valid_attributes[:url])
      @act.url(@learner).should eql(@valid_attributes[:url] + "?learner=34")
    end

    it "should return a correct url when appending to a url with existing params" do
      url = "http://www.concord.org/?foo=bar"
      @act.append_learner_id_to_url = true
      @act.url = url
      @act.url(@learner).should eql(url + "&learner=34")
    end
  end
end
