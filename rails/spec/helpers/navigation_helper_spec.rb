require 'spec_helper'

include ApplicationHelper
describe NavigationHelper, type: :helper  do
  let(:name) { "fredrique" }
  let(:itsi_links) do
    [
      double(position: 1, link_id: '/resources/activities', name: 'activities', href: '/itsi', pop_out: false),
      double(position: 2, link_id: '/resources/interactives', name: 'interactives', href: '/interactives', pop_out: true),
      double(position: 3, link_id: '/resources/images', name: 'images', href: '/images', pop_out: true),
      double(position: 4, link_id: '/resources/guides', name: 'Teacher Guides', href: 'https://guides.itsi.concord.org/', pop_out: true),
      double(position: 5, link_id: '/resources/careers', name: 'Careersight', href: 'https://careersight.concord.org/', pop_out: true),
      double(position: 6, link_id: '/resources/probes', name: 'Probesight', href: 'https://probesight.concord.org/', pop_out: true),
      double(position: 7, link_id: '/resources/schoology', name: 'Schoology', href: 'https://www.schoology.com/', pop_out: true)
    ]
  end
  let(:itsi_project) { double(links: itsi_links)}
  let(:fake_clazzes) { FactoryBot.create_list(:portal_clazz, 3)}
  let(:fake_inactive_clazz) { FactoryBot.create(:portal_clazz, is_archived: true)}
  let(:fake_student) { FactoryBot.create(:full_portal_student, clazzes: fake_clazzes) }
  let(:fake_researcher) {
    researcher = FactoryBot.generate(:researcher_user)
    researcher.researcher_for_projects << FactoryBot.create(:project)
    researcher
  }
  let(:fake_teacher) {
    teacher = FactoryBot.create(:portal_teacher, clazzes: fake_clazzes)
    teacher.teacher_clazzes.create(clazz: fake_inactive_clazz)
    teacher
  }
  let(:fake_visitor) { fake_student.user }
  let(:params)       { {greeting: "bonjour"} }
  let(:projects)     { [itsi_project] }
  before(:each) do
    allow(helper).to receive(:current_visitor).and_return(fake_visitor)
    allow(helper).to receive(:current_user).and_return(fake_visitor)
    allow(fake_visitor).to receive(:name).and_return(name)
    allow(fake_visitor).to receive(:projects).and_return(projects)
  end
  describe "fakes are setup" do
    describe "fake_teacher" do
      it "should have 4 clazzes" do
        expect(fake_teacher.clazzes.count).to eq(4)
      end
      it "should have 4 teacher_clazzes" do
        expect(fake_teacher.teacher_clazzes.count).to eq(4)
      end
      it "should have 3 active teacher_clazzes" do
        active_classes_count = 0;
        fake_teacher.teacher_clazzes.each do |tc|
          if !tc.clazz.is_archived
            active_classes_count = active_classes_count + 1
          end
        end
        expect(active_classes_count).to eq(3)
      end
    end
  end
  describe "get_nav_content" do
    describe "schema validation" do
      subject { helper.navigation_service(params).to_json }
      it { is_expected.to match_response_schema("navigation") }
    end
    describe "values" do
      subject { helper.navigation_service(params).to_hash }
      it { is_expected.to include(name:  name )}
      it { is_expected.to include(greeting: "bonjour") }
      it { is_expected.to include(:help) }
      it { is_expected.to include(:links) }
      it { is_expected.not_to include("xxx") }
    end
  end
  describe "teacher links" do
    let(:fake_visitor) { fake_teacher.user }
    subject { JSON.pretty_generate(helper.navigation_service(params).to_hash) }
    it "should inlude teacher links" do
      fake_clazzes.each do |clazz|
        expect(subject).to match %r{"url": "/portal/classes/#{clazz.id}/materials"}
        expect(subject).to match %r{"url": "/portal/classes/#{clazz.id}/roster"}
        expect(subject).to match %r{"url": "/portal/classes/#{clazz.id}/edit"}
        expect(subject).to match %r{"id": "/classes/#{clazz.id}"}
      end
      expect(subject).not_to match %r{"url": "/admin}
    end

    describe "teacher that is also a project admin" do
      before(:each) do
        allow(fake_visitor).to receive(:is_project_admin?).and_return(true)
      end
      it "should still include teacher clazz links" do
        fake_clazzes.each do |clazz|
          expect(subject).to match %r{"url": "/portal/classes/#{clazz.id}/materials"}
        end
      end
      it "should include admin links" do
        expect(subject).to match %r{"url": "/admin}
      end
      it "should include favorites links" do
        expect(subject).to match %r{"label": "Favorites"}
      end
    end
  end

  describe "student links" do
    let(:fake_visitor) { fake_student.user }
    subject { JSON.pretty_generate(helper.navigation_service(params).to_hash) }

    it "should include class links" do
      fake_teacher.reload
      fake_clazzes.each do |clazz|
        expect(subject).to match %r{"url": "/portal/classes/#{clazz.id}"}
      end
    end

    it "should not inlude teacher links" do
      fake_clazzes.each do |clazz|
        expect(subject).not_to match %r{"url": "/portal/classes/#{clazz.id}/materials"}
        expect(subject).not_to match %r{"url": "/portal/classes/#{clazz.id}/roster"}
        expect(subject).not_to match %r{"url": "/portal/classes/#{clazz.id}/edit"}
        expect(subject).not_to match %r{"section": "classes/#{clazz.name}"}
      end
      expect(subject).not_to match %r{"url": "/admin}
    end

    it "should not include favorites links" do
      expect(subject).not_to match %r{"label": "Favorites"}
    end

    it "should not include research project links" do
      expect(subject).not_to match %r{"label": "Research Projects"}
    end
  end

  describe "researcher links" do
    let(:fake_visitor) { fake_researcher }
    subject { JSON.pretty_generate(helper.navigation_service(params).to_hash) }

    it "should include research project links" do
      expect(subject).to match %r{"label": "Research Projects"}
    end
  end

  describe "selections" do
    let(:path) { "/" }
    let(:fake_visitor) { fake_teacher.user }
    subject { helper.navigation_service() }
    before(:each) do
      allow(helper).to receive_message_chain(:request, :path).and_return(path)
      subject.update_selection()
    end
    describe "when on the assignment page for the first class" do
      let(:path) { helper.url_for([:materials, clazz]) }
      let(:clazz) { fake_clazzes.first }
      it "should have the correct selected section" do
        expect(subject.selected_section).to eq("/classes/#{clazz.id}/assignments")
      end
      it "The selected link should be to the fake first class." do
        expect(subject.links.find { |l| l.selected }.label).to eq("Assignments")
      end
    end
  end

  describe "Links and sections for a teacher in ITSI" do
    let(:fake_visitor) { fake_teacher.user }
    subject { helper.navigation_service() }
    describe "In the ITSI Project" do
      let(:projects)     { [itsi_project] }

      it "should have several links" do
        expect(subject.links.size).to eq(26)
      end
      it "should have several sections" do
        expect(subject.sections.size).to eq(6)
      end
      it "should have resources, and classes sections" do
        expect(subject.sections.keys).to include("/resources", "/classes")
      end
    end

    describe "Not in any Projects" do
      let(:projects)     { [] }
      it "should have several links" do
        expect(subject.links.size).to eq(19)
      end
      it "should have several sections" do
        expect(subject.sections.size).to eq(5)
      end
      it "should not have resources sections" do
        expect(subject.sections.keys).not_to include("/resources")
      end
    end
  end

  describe "learner mode links" do
    subject { helper.navigation_service(params).to_hash }
    let(:labels) { subject[:links].map { |link| link[:label] } }
    let(:learner_user) { fake_teacher.find_or_create_teacher_preview_student! }
    let(:admin) { FactoryBot.generate(:admin_user) }

    describe "for a teacher" do
      let(:fake_visitor) { fake_teacher.user }

      it "shows 'Switch to Learner Mode (LM)' and not 'Switch back to teacher'" do
        link = subject[:links].find { |l| l[:label] == "Switch to Learner Mode (LM)" }
        # This teacher has no learner account yet, so the link is a GET to the explanation page.
        expect(link).to include(url: learner_mode_path)
        expect(link).not_to have_key(:httpMethod)
        expect(labels).not_to include("Switch back to teacher")
        expect(labels).not_to include("Switch back")
      end

      it "shows the name without the suffix" do
        expect(subject[:name]).to eq(name)
      end
    end

    describe "for a teacher with a learner account" do
      let(:fake_visitor) { fake_teacher.user }

      it "links 'Switch to Learner Mode (LM)' straight to the POST switch" do
        learner_user
        link = subject[:links].find { |l| l[:label] == "Switch to Learner Mode (LM)" }
        expect(link).to include(url: enter_learner_mode_path, httpMethod: "post")
      end
    end

    describe "for a learner account" do
      let(:fake_visitor) { learner_user }

      it "shows 'Switch back to teacher' and not 'Switch to Learner Mode (LM)'" do
        link = subject[:links].find { |l| l[:label] == "Switch back to teacher" }
        expect(link).to include(url: exit_learner_mode_path, httpMethod: "post")
        expect(labels).not_to include("Switch to Learner Mode (LM)")
        expect(labels).not_to include("Switch back")
      end

      it "shows the name with the (Learner) suffix" do
        expect(subject[:name]).to eq("#{name} (Learner)")
      end
    end

    describe "for a normal student" do
      let(:fake_visitor) { fake_student.user }

      it "shows no learner mode link" do
        expect(labels).not_to include("Switch to Learner Mode (LM)", "Switch back to teacher")
      end
    end

    describe "for an admin who switched into a normal student" do
      let(:fake_visitor) { fake_student.user }
      before(:each) { assign(:original_user, admin) }

      it "shows only 'Switch back'" do
        expect(labels).to include("Switch back")
        link = subject[:links].find { |l| l[:label] == "Switch back" }
        expect(link).to include(url: switch_back_user_path(fake_visitor), httpMethod: "post")
        expect(labels).not_to include("Switch to Learner Mode (LM)", "Switch back to teacher")
      end
    end

    describe "for an admin who switched into a teacher" do
      let(:fake_visitor) { fake_teacher.user }
      before(:each) { assign(:original_user, admin) }

      it "shows 'Switch back' and then 'Switch to Learner Mode (LM)'" do
        expect(labels).to include("Switch back", "Switch to Learner Mode (LM)")
        expect(labels.index("Switch back")).to be < labels.index("Switch to Learner Mode (LM)")
      end
    end

    describe "for an admin who switched into a teacher who then entered learner mode" do
      let(:fake_visitor) { learner_user }
      before(:each) { assign(:original_user, admin) }

      it "shows 'Switch back' and then 'Switch back to teacher'" do
        expect(labels).to include("Switch back", "Switch back to teacher")
        expect(labels.index("Switch back")).to be < labels.index("Switch back to teacher")
      end
    end
  end

  # TODO: auto-generated
  describe '#navigation_service' do
    it 'works' do
      result = helper.navigation_service(params)

      expect(result).not_to be_nil
    end
  end


end
