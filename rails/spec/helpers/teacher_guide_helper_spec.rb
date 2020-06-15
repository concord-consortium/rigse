require 'spec_helper'

include ApplicationHelper

describe TeacherGuideHelper, type: :helper do
  before :each do
    @helper = Object.new.extend TeacherGuideHelper
    @helper.extend ActionView::Helpers::UrlHelper
    allow(@helper).to receive(:tag_options).and_return({})
    allow(@helper).to receive(:current_user).and_return(user)
  end
  let(:is_admin)   {false}
  let(:is_teacher) {false}
  let(:stubs)      {{:has_role? => is_admin, :portal_teacher => is_teacher}}
  let(:user)       { mock_model(User, stubs)}
  let(:material)   { double({})}
  subject { @helper.teacher_guide_link(material)}
  describe "when the user isnt an admin" do
    describe "when the user isnt a teacher" do
      it { is_expected.to be_blank }
    end
    describe "when the user is a teacher" do
      let(:is_teacher) {true}
      let(:is_admin)   {false}
      describe "when there is no guide" do
        it { is_expected.to be_blank}
      end
      describe "When the guide is an empty string" do
        let(:material) {double({:teacher_guide_url => ""})}
        it {is_expected.to be_blank}
      end
      describe "When the guide is an actual url" do
        let(:material) {double({:teacher_guide_url => "http://google.com/"})}
        it {is_expected.to match "http://google.com"}
      end
    end
    describe "when the user is an admin" do
      let(:is_teacher) {false}
      let(:is_admin)   {true}
      describe "when there is no guide" do
        it { is_expected.to be_blank}
      end
      describe "When the guide is an empty string" do
        let(:material) {double({:teacher_guide_url => ""})}
        it {is_expected.to be_blank}
      end
      describe "When the guide is an actual url" do
        let(:material) {double({:teacher_guide_url => "http://google.com/"})}
        it {is_expected.to match "http://google.com"}
      end
    end
  end

  # TODO: auto-generated
  describe '#teacher_guide_link' do
    it 'works' do
      result = helper.teacher_guide_link('thing')

      expect(result).not_to be_nil
    end
  end


end
