require 'spec_helper'

include ApplicationHelper

describe TeacherGuideHelper do
  before :each do
    @helper = Object.new.extend TeacherGuideHelper
    @helper.extend ActionView::Helpers::UrlHelper
    @helper.stub!(:tag_options).and_return({})
    @helper.stub!(:current_user).and_return(user)
  end
  let(:is_admin)   {false}
  let(:is_teacher) {false}
  let(:stubs)      {{:has_role? => is_admin, :portal_teacher => is_teacher}}
  let(:user)       { mock_model(User, stubs)}
  let(:material)   { mock({})}
  subject { @helper.teacher_guide_link(material)}
  describe "when the user isnt an admin" do
    describe "when the user isnt a teacher" do
      it { should be_blank }
    end
    describe "when the user is a teacher" do
      let(:is_teacher) {true}
      let(:is_admin)   {false}
      describe "when there is no guide" do
        it { should be_blank}
      end
      describe "When the guide is an empty string" do
        let(:material) {mock({:teacher_guide_url => ""})}
        it {should be_blank}
      end
      describe "When the guide is an actual url" do
        let(:material) {mock({:teacher_guide_url => "http://google.com/"})}
        it {should match "http://google.com"}
      end
    end
    describe "when the user is an admin" do
      let(:is_teacher) {false}
      let(:is_admin)   {true}
      describe "when there is no guide" do
        it { should be_blank}
      end
      describe "When the guide is an empty string" do
        let(:material) {mock({:teacher_guide_url => ""})}
        it {should be_blank}
      end
      describe "When the guide is an actual url" do
        let(:material) {mock({:teacher_guide_url => "http://google.com/"})}
        it {should match "http://google.com"}
      end
    end
  end
end
