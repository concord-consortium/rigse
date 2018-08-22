require File.expand_path('../../spec_helper', __FILE__)

describe ExternalActivity do
  let(:valid_attributes) { {
      :user_id => 1,
      :uuid => "value for uuid",
      :name => "value for name",
      :long_description => "value for description",
      :long_description_for_teacher => "value for description for teachers",
      :publication_status => "value for publication_status",
      :is_featured => true,
      :is_official => true,
      :logging => true,
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
      expect(activity.url(learner)).to eql("http://www.concord.org/?learner=34#3")
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

  describe '#long_description_for_user' do
    let (:activity) { ExternalActivity.create!(valid_attributes) }
    let(:teacher_user) { t = FactoryGirl.create(:teacher); t.user }
    let(:student_user) { s = FactoryGirl.create(:portal_student); s.user }

    it 'should return value of long_description_for_teacher if user is a teacher' do
      expect(activity.long_description_for_user(teacher_user)).to eq(valid_attributes[:long_description_for_teacher])
    end
    it 'should return value of long_description if user is not a teacher' do
      expect(activity.long_description_for_user(student_user)).to eq(valid_attributes[:long_description])
    end
  end

  describe '#duplicate' do
    let(:project1) { FactoryGirl.create(:project) }
    let(:project2) { FactoryGirl.create(:project) }
    let(:user1) { t = FactoryGirl.create(:teacher); t.user }
    let(:user2) { t = FactoryGirl.create(:teacher); t.user }
    let(:template) { FactoryGirl.create(:investigation) }
    let(:activity) { a = ExternalActivity.create(valid_attributes); a.user = user1; a.save; a }
    # List of attributes that shouldn't match the original activity after duplication is done.
    let(:unique_attrs) do
      [ 'id', 'uuid', 'created_at', 'updated_at', 'name', 'user_id', 'publication_status',
        'template_id', 'template_type', 'is_official', 'is_featured', 'logging' ]
    end
    # Automatically generate all the attributes. This will let us test new automatically things when they are added.
    let(:attrs) { activity.attributes.except(*unique_attrs).keys }
    let(:clone) { activity.duplicate(user2) }
    let(:standard_statement) { FactoryGirl.create(:standard_statement, material_id: activity.id) }
    let(:cohort) { FactoryGirl.create(:admin_cohort) }
    let(:host) { "http://some.test.url.com" }

    before(:each) do
      user1.add_role_for_project('admin', project1)
      user1.add_role_for_project('admin', project2)
      # Second user is ad admin only for the project1.
      user2.add_role_for_project('admin', project1)

      # Randomize all the attributes of the activity.
      attrs.each_with_index do |attr, idx|
        activity.send("#{attr}=", case attr
                                    when 'url' then host + '/activity/1'
                                    when 'launch_url' then host + '/activity/1'
                                    else idx
                                  end
        )
      end

      activity.template = template
      activity.material_property_list = ['material_prop1', 'material_prop2']
      activity.grade_level_list = ['gradel1', 'gradel2']
      activity.subject_area_list = ['sa1', 'sa2']
      activity.sensor_list = ['sensor1', 'sensor2']
      activity.project_ids = [project1.id, project2.id]
      activity.set_cohorts_by_id(cohort.id)
      # This will trigger creation of standard statement.
      standard_statement

      activity.save!
    end

    it "should copy basic attributes (except small subset) and assign a new user" do
      expect(clone.publication_status).to eq("private")
      expect(clone.is_official).to eq(false)
      expect(clone.is_featured).to eq(false)
      expect(clone.logging).to eq(true) # because user is a project admin
      expect(clone.user).to eq(user2)
      expect(clone.name).to eq("Copy of " + activity.name)
      # Automatically check all the attributes.
      attrs.each do |attr|
        expect(clone.send(attr)).to eq(activity.send(attr))
      end
    end

    describe "when user is not an admin or project admin" do
      before(:each) do
        user2.remove_role_for_project('admin', project1)
      end
      it "should NOT copy logging option" do
        expect(clone.logging).to eq(false)
      end
    end

    it "should copy tags" do
      expect(clone.material_property_list).to eq(activity.material_property_list)
      expect(clone.grade_level_list).to eq(activity.grade_level_list)
      expect(clone.subject_area_list).to eq(activity.subject_area_list)
      expect(clone.sensor_list).to eq(activity.sensor_list)
    end

    it "should copy projects that new owner can manage" do
      expect(clone.project_ids).to eq([ project1.id ])
    end

    it "should copy standard statements" do
      ss = StandardStatement.find_all_by_material_type_and_material_id('external_activity', clone.id)
      expect(ss.count).to eq(1)
      expect(ss.first.uri).to eq(standard_statement.uri)
    end

    it "should NOT copy cohorts" do
      expect(clone.cohorts).to eq([])
    end

    it "should NOT copy template" do
      expect(activity.template).to be(template)
      expect(clone.template_id).to be_nil
      expect(clone.template_type).to be_nil
    end

    describe "when external activity is a LARA activity" do
      let(:secret) { 'secret' }
      let(:root_url) { 'http://portal.concord.org' }
      let(:clone) { activity.duplicate(user2, root_url) }
      let(:lara_response) do
        {
          'publication_data' => {
            'type' => 'Activity',
            'url' => valid_attributes[:url],
            'launch_url' => valid_attributes[:url],
            'thumbnail_url' => 'http://image.com',
            "sections" => [
              {
                "name" => "Activity Section 1",
                "pages" => [
                  {
                    "name" => "Activity Page 1",
                    "url" => "https://some.url",
                    "elements" => [
                      {
                        "type" => "open_response",
                        "id" => "1234568",
                        "prompt" => "Why do you like/dislike this activity?"
                      }
                    ]
                  }
                ]
              }
            ]
          }
        }
      end

      before(:each) do
        activity.source_type = 'LARA'
        activity.save

        WebMock.stub_request(:post, activity.url + '/remote_duplicate')
          .to_return(:status => 200, :body => lara_response.to_json)

        FactoryGirl.create(:client, site_url: host, app_secret: secret)
      end

      it "it should communicate LARA, request remote duplication and perform publishing" do
        clone.reload
        expect(clone.thumbnail_url).to eq(lara_response['publication_data']['thumbnail_url'])
        expect(clone.template).not_to be_nil
        expect(WebMock).to have_requested(:post, activity.url + '/remote_duplicate')
          .with(body: {
            user_email: user2.email,
            add_to_portal: root_url
          }.to_json)
          .with(headers: {
            'Authorization' => 'Bearer ' + secret,
            'Content-Type'=>'application/json'
          })
          .once
      end
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
