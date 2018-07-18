require File.expand_path('../../spec_helper', __FILE__)

describe ExternalActivity do
  let(:valid_attributes) { {
      :user_id => 1,
      :uuid => "value for uuid",
      :name => "value for name",
      :long_description => "value for description",
      :long_description_for_teacher => "value for description for teachers",
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
      activity.url(learner).should eql("http://www.concord.org/?learner=34#3")
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

  describe '#long_description_for_user' do
    let (:activity) { ExternalActivity.create!(valid_attributes) }
    let(:teacher_user) { t = FactoryGirl.create(:teacher); t.user }
    let(:student_user) { s = FactoryGirl.create(:portal_student); s.user }

    it 'should return value of long_description_for_teacher if user is a teacher' do
      activity.long_description_for_user(teacher_user).should == valid_attributes[:long_description_for_teacher]
    end
    it 'should return value of long_description if user is not a teacher' do
      activity.long_description_for_user(student_user).should == valid_attributes[:long_description]
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
        :long_description => "value for description",
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
