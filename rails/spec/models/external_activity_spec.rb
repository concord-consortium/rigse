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

    it "should append a JWT token when append_auth_token is true" do
      user = FactoryBot.create(:confirmed_user)
      real_learner = mock_model(Portal::Learner, id: 34, user: user)
      activity.append_auth_token = true
      url = activity.url(real_learner)
      uri = URI.parse(url)
      query = URI.decode_www_form(uri.query)
      token_param = query.find { |k, _| k == "token" }
      expect(token_param).not_to be_nil
      # JWT tokens contain dots (header.payload.signature)
      expect(token_param[1]).to include(".")
      # Verify it's a valid portal JWT with learner claims
      decoded = SignedJwt.decode_portal_token(token_param[1])
      expect(decoded[:data]["uid"]).to eq(user.id)
      expect(decoded[:data]["learner_id"]).to eq(34)
      expect(decoded[:data]["user_type"]).to eq("learner")
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
    let(:teacher_user) { t = FactoryBot.create(:teacher); t.user }
    let(:student_user) { s = FactoryBot.create(:portal_student); s.user }

    it 'should return value of long_description_for_teacher if user is a teacher' do
      expect(activity.long_description_for_user(teacher_user)).to eq(valid_attributes[:long_description_for_teacher])
    end
    it 'should return value of long_description if user is not a teacher' do
      expect(activity.long_description_for_user(student_user)).to eq(valid_attributes[:long_description])
    end
  end

  describe "project support" do
    let (:activity) { FactoryBot.create(:external_activity) }
    let (:project) { FactoryBot.create(:project) }

    it "can be assigned to a project" do
      activity.projects << project
      expect(activity.projects.count).to eql(1)
    end
  end

  describe "external" do
    let(:lara_tool) { Tool.create!(
      :id => 1,
      :name => "LARA",
      :source_type => "LARA",
      :tool_id => "http://lara.url/"
    )}
    let(:ap_tool) { Tool.create!(
      :id => 2,
      :name => "Activity Player",
      :source_type => "Activity Player",
      :tool_id => "http://activityplayer.url/"
    )}
    let(:lara_attributes) { {
        :user_id => 1,
        :uuid => "value for uuid",
        :name => "value for name",
        :long_description => "value for description",
        :publication_status => "value for publication_status",
        :is_official => true,
        :url => "http://www.concord.org/lara",
        :template_type => "Activity",
        :tool_id => lara_tool.id
    } }
    let(:ap_attributes) { {
        :user_id => 1,
        :uuid => "value for uuid",
        :name => "value for name",
        :long_description => "value for description",
        :publication_status => "value for publication_status",
        :is_official => true,
        :url => "http://www.concord.org/ap",
        :template_type => "Activity",
        :tool_id => ap_tool.id
    } }
    let(:lara_activity) { ExternalActivity.create!(lara_attributes)}
    let(:ap_activity) { ExternalActivity.create!(ap_attributes)}

    it "activities with LARA as its tool should return true for lara_activity_or_sequence?" do
      expect(lara_activity.lara_activity_or_sequence?).to be true
    end
    it "activities with something other than LARA as a tool should return false for lara_activity_or_sequence?" do
      expect(ap_activity.lara_activity_or_sequence?).to be false
    end
  end

  # TODO: auto-generated
  describe '.published' do # scope test
    it 'supports named scope published' do
      expect(described_class.limit(3).published).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.assigned' do # scope test
    it 'supports named scope assigned' do
      expect(described_class.limit(3).assigned).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.not_private' do # scope test
    it 'supports named scope not_private' do
      expect(described_class.limit(3).not_private).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.by_user' do # scope test
    it 'supports named scope by_user' do
      expect(described_class.limit(3).by_user(FactoryBot.create(:user))).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.ordered_by' do # scope test
    it 'supports named scope ordered_by' do
      expect(described_class.limit(3).ordered_by(nil)).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.official' do # scope test
    it 'supports named scope official' do
      expect(described_class.limit(3).official).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.contributed' do # scope test
    it 'supports named scope contributed' do
      expect(described_class.limit(3).contributed).to all(be_a(described_class))
    end
  end
  # TODO: auto-generated
  describe '.archived' do # scope test
    it 'supports named scope archived' do
      expect(described_class.limit(3).archived).to all(be_a(described_class))
    end
  end

  # TODO: auto-generated
  describe '#material_type' do
    it 'material_type' do
      external_activity = described_class.new
      result = external_activity.material_type

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#template=' do
    xit 'template=' do
      external_activity = described_class.new
      t = 't'
      result = external_activity.template=(t)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#original_template=' do
    xit 'original_template=' do
      external_activity = described_class.new
      t = 't'
      result = external_activity.original_template=(t)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#valid_url' do
    it 'valid_url' do
      external_activity = described_class.new
      result = external_activity.valid_url

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#url' do
    it 'url' do
      external_activity = described_class.new
      learner = double('learner')
      domain = double('domain')
      result = external_activity.url(learner, domain)

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#display_name' do
    it 'display_name' do
      external_activity = described_class.new
      result = external_activity.display_name

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#teacher_only' do
    it 'teacher_only' do
      external_activity = described_class.new
      result = external_activity.teacher_only

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#teacher_only?' do
    it 'teacher_only?' do
      external_activity = described_class.new
      result = external_activity.teacher_only?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#parent' do
    it 'parent' do
      external_activity = described_class.new
      result = external_activity.parent

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#left_nav_panel_width' do
    it 'left_nav_panel_width' do
      external_activity = described_class.new
      result = external_activity.left_nav_panel_width

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#print_listing' do
    it 'print_listing' do
      external_activity = described_class.new
      result = external_activity.print_listing

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#run_format' do
    it 'run_format' do
      external_activity = described_class.new
      result = external_activity.run_format

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#lara_activity_or_sequence?' do
    it 'lara_activity_or_sequence?' do
      external_activity = described_class.new
      result = external_activity.lara_activity_or_sequence?

      expect(result).not_to be_nil
    end
  end

  describe "external_reports" do
    let(:activity) { described_class.create(valid_attributes) }

    let(:report_a_props) do
      {
        url: "http://a/report.html",
        name: "a",
        launch_text: "a"
      }
    end

    let(:report_b_props) do
      {
        url: "http://b/report.html",
        name: "b",
        launch_text: "b"
      }
    end

    let(:report_a) { ExternalReport.create(report_a_props) }
    let(:report_b) { ExternalReport.create(report_b_props) }
    it "doesn't have an external_report at first" do
      expect(activity).to be_valid
      expect(activity.external_reports).to be_empty
    end

    it "can have multiple external reports" do
      activity.external_reports.create(report_a_props)
      activity.external_reports.create(report_b_props)
      expect(activity.external_reports).to have(2).reports
    end

    it "will return the first external report when asked for just one" do
      activity.external_reports.create(report_a_props)
      activity.external_reports.create(report_b_props)
      expect(activity.external_report).to eql activity.external_reports.first
    end

  end


end
