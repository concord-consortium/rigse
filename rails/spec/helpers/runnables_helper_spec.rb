require 'spec_helper'

include ApplicationHelper
describe RunnablesHelper, type: :helper  do
  let(:component) { User.new }
  include RunnablesLinkMatcher
  before :each do
    @anonymous_user = mock_model(User, :roles => ["guest"], :anonymous? => true, :name => "guest")
    allow(helper).to receive(:current_visitor).and_return(@anonymous_user)
    allow(helper).to receive(:authenticate_with_http_basic).and_return nil
  end

  describe ".display_workgroups_run_link?" do
    context "with workgroups enabled" do
      before :each do
        allow(helper).to receive(:use_adhoc_workgroups?).and_return true
      end

      context "with runnables" do
        let :offering do
          double(:runnable => Object.new)
        end
        it "should return false" do
          expect(helper.display_workgroups_run_link?(offering)).to be_falsey
        end
      end
    end
  end

  describe ".display_status_updates?" do
      context "with simpler offering" do
        let :offering do
          double(:runnable => Object.new())
        end
        it "should return false" do
          expect(helper.display_status_updates?(offering)).to be_falsey
        end
      end

  end

  describe ".student_run_buttons" do

  end

  # Shows up in _offering_for_student eg.
  describe ".runnable_type_label" do
    let(:template_type) { nil}
    let(:runnable) { mock_model(ExternalActivity, :template_type => template_type) }
    let(:offering) { mock_model(Portal::Offering, :runnable => runnable )}
    subject { helper.runnable_type_label(offering) }

    describe "for an external activity offering" do
      describe "when the external activity template is nil" do
        it "should include the word investigation (or sequence)" do
          expect(runnable.template_type).to be_nil
          expect(subject).to eq(t('activerecord.models.ExternalActivity'))
        end
      end

      describe "when the external activity template is an investigation" do
        let(:runnable) { mock_model(ExternalActivity, :template_type => "Investigation", :material_type => "Investigation" )}
        it "should include the word investigation (or sequence)" do
          expect(subject).to eq(t('activerecord.models.Investigation'))
        end
      end

      describe "when the external activity template is an activity" do
        let(:runnable) { mock_model(ExternalActivity, :template_type => "Activity", :material_type => "Activity" )}
        it "should include the word investigation (or sequence)" do
          expect(subject).to eq(t('activerecord.models.Activity'))
        end
      end
    end

    describe "for an investigation offering" do
      let(:runnable) { mock_model(Investigation)}
      it "should include the word investigation (or sequence)" do
        expect(subject).to eq(t('activerecord.models.Investigation'))
      end
    end

    describe "for an activity offering" do
      let(:runnable) { mock_model(Activity)}
      it "should include the word Activity" do
        expect(subject).to eq(t('activerecord.models.Activity'))
      end
    end

    describe "for an activity runnable" do
      let(:offering) { mock_model(Activity)}
      it "should include the word Activity" do
        expect(subject).to eq(t('activerecord.models.Activity'))
      end
    end

  end

  # TODO: auto-generated
  describe '#use_adhoc_workgroups?' do
    it 'works' do
      result = helper.use_adhoc_workgroups?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#student_run_button_css' do
    it 'works' do
      result = helper.student_run_button_css(FactoryBot.create(:portal_offering), [])

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#title_text' do
    xit 'works' do
      result = helper.title_text(component, 'verb')

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#updated_time_text' do
    it 'works' do
      result = helper.updated_time_text('thing')

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#run_url_for' do
    xit 'works' do
      result = helper.run_url_for(component, {}, 'format')

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#popup_options_for' do
    it 'works' do
      result = helper.popup_options_for(component, {})

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#x_button_for' do
    xit 'works' do
      result = helper.x_button_for(component, 'verb', 'image')

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#x_link_for' do
    xit 'works' do
      result = helper.x_link_for(component, 'verb')

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#preview_button_for' do
    xit 'works' do
      result = helper.preview_button_for(FactoryBot.create(:portal_offering), {}, img, run_as)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#preview_link_for' do
    xit 'works' do
      result = helper.preview_link_for(FactoryBot.create(:portal_offering))

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#offering_link_for' do
    xit 'works' do
      result = helper.offering_link_for(FactoryBot.create(:portal_offering))

      expect(result).not_to be_nil
    end
  end

  describe '#preview_params' do
    let(:user) { FactoryBot.create(:user) }

    it 'should work without params'  do
      result = helper.preview_params(user)
      expect(result.to_json).to eq("{}")
    end

    it 'should work with params by cloning them'  do
      original_params = {foo: "bar"}
      result = helper.preview_params(user, original_params)
      expect(result.to_json).to eq('{"foo":"bar"}')
      expect(result).not_to equal(original_params)
    end

    describe 'for teachers' do
      let(:user) { t = FactoryBot.create(:teacher); t.user }
      it 'should add logging automatically'  do
        result1 = helper.preview_params(user)
        expect(result1.to_json).to eq('{"logging":true}')

        result2 = helper.preview_params(user, {foo: "bar"})
        expect(result2.to_json).to eq('{"foo":"bar","logging":true}')
      end
    end
  end

end
