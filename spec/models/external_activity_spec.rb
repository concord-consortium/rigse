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
      expect(activity.append_learner_id_to_url).to be_falsey
    end

    it "should return the original url when appending is false" do
      expect(activity.url).to eql(valid_attributes[:url])
      expect(activity.url(learner)).to eql(valid_attributes[:url])
    end

    it "should return a modified url when appending is true" do
      activity.append_learner_id_to_url = true
      expect(activity.url).to eql(valid_attributes[:url])
      expect(activity.url(learner)).to eql(valid_attributes[:url] + "?learner=34")
    end

    it "should return a correct url when appending to a url with existing params" do
      url = "http://www.concord.org/?foo=bar"
      activity.append_learner_id_to_url = true
      activity.url = url
      expect(activity.url(learner)).to eql(url + "&learner=34")
    end

    it "should return a correct url when appending to a url with existing fragment" do
      url = "http://www.concord.org/#3"
      activity.append_learner_id_to_url = true
      activity.url = url
      expect(activity.url(learner)).to eql(url + "?learner=34")
    end
  end

  describe '#material_type override' do
    let (:activity) { ExternalActivity.create!(valid_attributes) }
    let (:real_activity) { Activity.create!( :name => "test activity", :description => "new decription" ) }
    let (:investigation) { Investigation.create!(:name => "test investigation", :description => "new decription") }

    it 'should return template_type for EAs with templates' do
      activity.template = real_activity
      expect(activity.material_type).to eq('Activity')
      activity.template = investigation
      expect(activity.material_type).to eq('Investigation')
    end
  end

  describe '#full_title' do
    let (:activity) { ExternalActivity.create!(valid_attributes) }
    it 'should return external activity name (compatibility with regular activities and sequences)' do
      expect(activity.full_title).to eq(valid_attributes[:name])
    end
  end

  describe "abstract_text" do
    let(:abstract)    { nil }
    let(:big_text)    { "-xyzzy" * 255 }
    let(:description) do
      "This is the description. Its text is too long to be an abstract really: #{big_text}"
    end
    let(:abstract)    { nil }
    subject { ExternalActivity.create(:name => 'test', :abstract => abstract, :description => description).abstract_text }
    describe "without an abstract" do
      let(:abstract)         { nil }
      it { is_expected.to match /This is the description./ }
      it 'has at most 255 letters' do
        expect(subject.size).to be <= 255
      end
    end
    describe "without an empty abstract" do
      let(:abstract)         { " " }
      it { is_expected.to match /This is the description./ }
      it 'has at most 255 letters' do
        expect(subject.size).to be <= 255
      end
    end
    describe "without a good abstract" do
      let(:abstract)         { "This is the abstract." }
      it { is_expected.to match /This is the abstract./ }
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

  describe "external" do
    let(:lara_launch_url_attributes) { {
        :user_id => 1,
        :uuid => "value for uuid",
        :name => "value for name",
        :description => "value for description",
        :publication_status => "value for publication_status",
        :is_official => true,
        :url => "http://www.concord.org/",
        :template_type => "Activity",
        :launch_url => "http://authoring.concord.org/"
    } }
    let(:activity) { ExternalActivity.create!(lara_launch_url_attributes)}

    it "activities with launch urls should return true for lara_activity?" do
      expect(activity.lara_activity?).to be true
    end
    it "activities wihtout launch urls should return false for lara_activity?" do
      activity.launch_url = nil
      expect(activity.lara_activity?).to be false
    end
  end
end
