require File.expand_path('../../spec_helper', __FILE__)

describe ExternalActivity do
  let(:valid_attributes) { {
      :user_id => 1,
      :uuid => "value for uuid",
      :name => "value for name",
      :description => "value for description",
      :publication_status => "value for publication_status",
      :is_official => true,
      :url => "http://www.concord.org/"
  } }

  it "should create a new instance given valid attributes" do
    ExternalActivity.create!(valid_attributes)
  end

  describe "url transforms" do
    let(:activity) { ExternalActivity.create!(valid_attributes)}
    let(:learner) { mock_model(Portal::Learner, :id => 34) }

    it "should default to not appending the learner id to the url" do
      activity.append_learner_id_to_url.should be_false
    end

    it "should return the original url when appending is false" do
      activity.url.should eql(valid_attributes[:url])
      activity.url(learner).should eql(valid_attributes[:url])
    end

    it "should return a modified url when appending is true" do
      activity.append_learner_id_to_url = true
      activity.url.should eql(valid_attributes[:url])
      activity.url(learner).should eql(valid_attributes[:url] + "?learner=34")
    end

    it "should return a correct url when appending to a url with existing params" do
      url = "http://www.concord.org/?foo=bar"
      activity.append_learner_id_to_url = true
      activity.url = url
      activity.url(learner).should eql(url + "&learner=34")
    end

    it "should return a correct url when appending to a url with existing fragment" do
      url = "http://www.concord.org/#3"
      activity.append_learner_id_to_url = true
      activity.url = url
      activity.url(learner).should eql(url + "?learner=34")
    end
  end

  describe '#material_type override' do
    let (:activity) { ExternalActivity.create!(valid_attributes) }
    let (:real_activity) { Activity.create!( :name => "test activity", :description => "new decription" ) }
    let (:investigation) { Investigation.create!(:name => "test investigation", :description => "new decription") }

    it 'should return template_type for EAs with templates' do
      activity.template = real_activity
      activity.material_type.should == 'Activity'
      activity.template = investigation
      activity.material_type.should == 'Investigation'
    end
  end

  describe '#full_title' do
    let (:activity) { ExternalActivity.create!(valid_attributes) }
    it 'should return external activity name (compatibility with regular activities and sequences)' do
      activity.full_title.should == valid_attributes[:name]
    end
  end

  describe "abstract_text" do
    let(:abstract)    { nil }
    let(:big_text)    { "-xyzzy" * 255 }
    let(:description) do
      "This is the description. Its text is too long to be an abstract really: #{big_text}"
    end
    let(:abstract)    { nil }
    subject { ExternalActivity.create(:name => 'test', :abstract => abstract, :description => description) }
    describe "without an abstract" do
      let(:abstract)         { nil }
      its(:abstract_text)    { should match /This is the description./ }
      its(:abstract_text)    { should have_at_most(255).letters }
    end
    describe "without an empty abstract" do
      let(:abstract)         { " " }
      its(:abstract_text)    { should match /This is the description./ }
      its(:abstract_text)    { should have_at_most(255).letters }
    end
    describe "without a good abstract" do
      let(:abstract)         { "This is the abstract." }
      its(:abstract_text)    { should match /This is the abstract./ }
    end
  end

  describe "project support" do
    let (:activity) { FactoryGirl.create(:external_activity) }
    let (:project) { FactoryGirl.create(:project) }

    it "can be assigned to a project" do
      activity.projects << project
      expect(activity.projects.count).to eql(1)
    end
  end
end
