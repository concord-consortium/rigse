require 'spec_helper'

include ApplicationHelper
describe NavigationHelper, type: :helper  do
  let(:name) { "fredrique" }
  let(:itsi_links) do
    [
      double(link_id: '/resources/activities', name: 'activities', href: '/itsi', pop_out: false),
      double(link_id: '/resources/interactives', name: 'interactives', href: '/interactives', pop_out: true),
      double(link_id: '/resources/images', name: 'images', href: '/images', pop_out: true),
      double(link_id: '/resources/guides', name: 'Teacher Guides', href: 'https://guides.itsi.concord.org/', pop_out: true),
      double(link_id: '/resources/careers', name: 'Careersight', href: 'https://careersight.concord.org/', pop_out: true),
      double(link_id: '/resources/probes', name: 'Probesight', href: 'https://probesight.concord.org/', pop_out: true),
      double(link_id: '/resources/schoology', name: 'Schoology', href: 'https://www.schoology.com/', pop_out: true)
    ]
  end
  let(:itsi_project) { double(links: itsi_links)}
  let(:fake_clazzes) { FactoryGirl.create_list(:portal_clazz, 3)}
  let(:fake_teacher_clazzes) { fake_clazzes.map { |c| double(clazz: c)}}
  let(:fake_student) { FactoryGirl.create(:full_portal_student) }
  let(:fake_teacher) { FactoryGirl.create(:portal_teacher) }
  let(:fake_visitor) { fake_student.user }
  let(:params)       { {greeting: "bonjour"} }
  let(:projects)     { [itsi_project] }
  before(:each) do
    allow(helper).to receive(:current_visitor).and_return(fake_visitor)
    allow(helper).to receive(:current_user).and_return(fake_visitor)
    allow(fake_visitor).to receive(:name).and_return(name)
    allow(fake_visitor).to receive(:projects).and_return(projects)
    allow(fake_teacher).to receive(:teacher_clazzes).and_return(fake_teacher_clazzes)
    allow(fake_student).to receive(:clazzes).and_return(fake_clazzes)
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
      fake_clazzes.each do |clazz|
        expect(subject).to match %r{"url": "/portal/classes/#{clazz.id}"}
      end
    end

    it "should not inlude teacher links" do
      fake_clazzes.each do |clazz|
        expect(subject).not_to match %r{"url": "/portal/classes/#{clazz.id}/materials"}
        expect(subject).not_to match %r{"url": "/portal/classes/#{clazz.id}/roster"}
        expect(subject).not_to match %r{"url": "/portal/classes/#{clazz.id}/edit"}
        expect(subject).not_to match %r{"url": "/portal/classes/#{clazz.id}/fullstatus"}
        expect(subject).not_to match %r{"section": "classes/#{clazz.name}"}
      end
      expect(subject).not_to match %r{"url": "/admin}
    end

    it "should not include favorites links" do
      expect(subject).not_to match %r{"label": "Favorites"}
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
        expect(subject.links.size).to eq(24)
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
        expect(subject.links.size).to eq(17)
      end
      it "should have several sections" do
        expect(subject.sections.size).to eq(5)
      end
      it "should not have resources sections" do
        expect(subject.sections.keys).not_to include("/resources")
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
