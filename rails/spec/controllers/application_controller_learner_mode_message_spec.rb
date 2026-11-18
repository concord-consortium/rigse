require File.expand_path('../../spec_helper', __FILE__)

# When a page is refused, both a teacher learner user and a teacher user with a linked teacher
# learner get extra text. They may have switched accounts in another tab, because all tabs
# share one session.
describe ApplicationController, type: :controller do
  controller do
    def index
      raise Pundit::NotAuthorizedError
    end
  end

  let(:to_learner_text) { LearnerModeTextHelper::SWITCHED_TO_LEARNER_TEXT }
  let(:to_teacher_text) { LearnerModeTextHelper::SWITCHED_TO_TEACHER_TEXT }

  let(:teacher)      { FactoryBot.create(:portal_teacher) }
  let(:learner_user) { teacher.find_or_create_teacher_learner! }
  let(:student_user) { FactoryBot.create(:full_portal_student).user }

  before(:each) do
    generate_default_settings_with_mocks
  end

  def refusal_message(user, xhr: false)
    sign_in user
    get :index, xhr: xhr
    xhr ? Nokogiri::HTML.fragment(response.body).at_css('div.flash_error')&.text : flash['alert']
  end

  describe 'on a page load' do
    it 'adds the text for a learner account' do
      expect(refusal_message(learner_user)).to eq("You don't have permission to list this resource. #{to_learner_text}")
    end

    it 'adds the text for a teacher with a learner account' do
      learner_user
      expect(refusal_message(teacher.user)).to eq("You don't have permission to list this resource. #{to_teacher_text}")
    end

    it 'does not add the text for a teacher with no learner account' do
      expect(refusal_message(teacher.user)).to eq("You don't have permission to list this resource")
    end

    it 'does not add the text for a normal student' do
      expect(refusal_message(student_user)).to eq("You don't have permission to list this resource")
    end
  end

  describe 'on a background (xhr) request' do
    it 'adds the text for a learner account' do
      expect(refusal_message(learner_user, xhr: true)).to include(to_learner_text)
      expect(response).to have_http_status(:forbidden)
    end

    it 'adds the text for a teacher with a learner account' do
      learner_user
      expect(refusal_message(teacher.user, xhr: true)).to include(to_teacher_text)
    end

    it 'does not add the text for a teacher with no learner account' do
      expect(refusal_message(teacher.user, xhr: true)).not_to include('another tab')
    end

    it 'does not add the text for a normal student' do
      expect(refusal_message(student_user, xhr: true)).not_to include('another tab')
    end

    it 'sends the message as text inside a real div' do
      allow(controller).to receive(:not_authorized_error_message).and_return("Can't see <b>class</b>")
      expect(refusal_message(student_user, xhr: true)).to eq("Can't see <b>class</b>")
      expect(response.body).to eq('<div class="flash_error">Can&#39;t see &lt;b&gt;class&lt;/b&gt;</div>')
    end
  end
end
