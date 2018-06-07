require 'spec_helper'



include ApplicationHelper
describe NavigationHelper do
  let(:name) { "fredrique" }
  let(:fake_clazzes) { FactoryGirl.create_list(:portal_clazz, 3)}
  let(:fake_teacher_clazzes) { fake_clazzes.map { |c| mock(clazz: c)}}
  let(:fake_student) { FactoryGirl.create(:full_portal_student) }
  let(:fake_teacher) { FactoryGirl.create(:portal_teacher) }
  let(:fake_visitor) { fake_student.user }
  let(:params)       { {greeting: "bonjour"} }
  before(:each) do
    helper.stub(:current_visitor).and_return(fake_visitor)
    helper.stub(:current_user).and_return(fake_visitor)
    fake_visitor.stub(:name).and_return(name)
    fake_teacher.stub(:teacher_clazzes).and_return(fake_teacher_clazzes)
    fake_student.stub(:clazzes).and_return(fake_clazzes)
  end
  describe "get_nav_content" do
    describe "schema validation" do
      subject { helper.navigation_service(params).to_json }
      it { should match_response_schema("navigation") }
    end
    describe "values" do
      subject { helper.navigation_service(params).to_hash }
      it { should include(name:  name )}
      it { should include(greeting: "bonjour") }
      it { should include(:help) }
      it { should include(:links) }
      it { should_not include("xxx") }
    end
  end
  describe "teacher links" do
    let(:fake_visitor) { fake_teacher.user }
    subject { JSON.pretty_generate(helper.navigation_service(params).to_hash) }
    it "should inlude teacher links" do
      fake_clazzes.each do |clazz|
        subject.should match %r{"url": "/portal/classes/#{clazz.id}"}
        subject.should match %r{"url": "/portal/classes/#{clazz.id}/materials"}
        subject.should match %r{"url": "/portal/classes/#{clazz.id}/roster"}
        subject.should match %r{"url": "/portal/classes/#{clazz.id}/edit"}
        subject.should match %r{"url": "/portal/classes/#{clazz.id}/fullstatus"}
        subject.should match %r{"section": "classes/#{clazz.name}"}
      end
      subject.should_not match %r{"url": "/admin}
    end

    describe "teacher that is also a project admin" do
      before(:each) do
        fake_visitor.stub(:is_project_admin?).and_return(true)
      end
      it "should still include teacher clazz links" do
        fake_clazzes.each do |clazz|
          subject.should match %r{"url": "/portal/classes/#{clazz.id}/materials"}
        end
      end
      it "should include admin links" do
        subject.should match %r{"url": "/admin}
      end
      it "should include favorites links" do
        subject.should match %r{"label": "Favorites"}
      end
    end
  end

  describe "student links" do
    let(:fake_visitor) { fake_student.user }
    subject { JSON.pretty_generate(helper.navigation_service(params).to_hash) }

    it "should include class links" do
      fake_clazzes.each do |clazz|
        subject.should match %r{"url": "/portal/classes/#{clazz.id}"}
      end
    end

    it "should not inlude teacher links" do
      fake_clazzes.each do |clazz|
        subject.should_not match %r{"url": "/portal/classes/#{clazz.id}/materials"}
        subject.should_not match %r{"url": "/portal/classes/#{clazz.id}/roster"}
        subject.should_not match %r{"url": "/portal/classes/#{clazz.id}/edit"}
        subject.should_not match %r{"url": "/portal/classes/#{clazz.id}/fullstatus"}
        subject.should_not match %r{"section": "classes/#{clazz.name}"}
      end
      subject.should_not match %r{"url": "/admin}
    end

    it "should not include favorites links" do
      subject.should_not match %r{"label": "Favorites"}
    end
  end

  describe "selections" do
    let(:path) { "/" }
    before(:each) do
      helper.stub_chain(:request, :path).and_return(path)
      puts path
    end
    let(:fake_visitor) { fake_teacher.user }
    subject { helper.navigation_service() }
    it "should have several links" do
      subject.links.should have(20).links
    end
    describe "when on the assignment page for the first class" do
      let(:path) { helper.url_for([:materials, clazz]) }
      let(:clazz) { fake_clazzes.first }
      it "should have the correct selected section" do
        subject.selected_section.should == "classes/#{clazz.name}"
      end
      it "The selected link should be to the fake first class." do
        subject.links.find { |l| l.selected }.label.should == "Assignments"
      end
    end
  end
end
