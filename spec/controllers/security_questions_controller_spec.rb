require File.expand_path('../../spec_helper', __FILE__)

describe SecurityQuestionsController do
  render_views

  before(:each) do
    @student = Factory.create(:portal_student, :user => Factory.create(:confirmed_user))
    sign_in @student.user
    @test_settings = double("settings",:name=> "Test Settings")
    expect(@test_settings).to receive(:use_student_security_questions).and_return(true)
    allow(@test_settings).to receive(:require_user_consent?).and_return(false)
    allow(@test_settings).to receive(:help_type).and_return('no help')
    allow(@test_settings).to receive(:enabled_bookmark_types).and_return([])
    allow(@test_settings).to receive(:anonymous_can_browse_materials).and_return(true)
    allow(@test_settings).to receive(:show_collections_menu).and_return(false)
    allow(@test_settings).to receive(:auto_set_teachers_as_authors).and_return(false)
    allow(@test_settings).to receive(:teacher_home_path).and_return(nil)
    allow(Admin::Settings).to receive(:default_settings).and_return(@test_settings)
  end

  describe "GET edit" do
    it "fills in the form with the student's current security questions, if any" do
      @student.user.security_questions.create({ :question => "Test question 1", :answer => "test answer 1" })
      @student.user.security_questions.create({ :question => "Test question 2", :answer => "test answer 2" })

      get :edit

      @student.user.security_questions.each_with_index do |q, i|
        assert_select("select[name=?]", "security_questions[question#{i}][question_idx]") do
          assert_select("option[value='current']", :text => q.question_idx)
        end
        assert_select("input[name=?][value=?]", "security_questions[question#{i}][answer]", q.answer)
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @params_for_update = {
        :security_questions => {
          :question0 => {
            :question_idx => 0,
            :answer => "test answer"
          },
          :question1 => {
            :question_idx => 1,
            :answer => "test answer"
          },
          :question2 => {
            :question_idx => 2,
            :answer => "test answer"
          }
        }
      }
    end

    it "updates the user's security questions" do
      expect(SecurityQuestion).to receive(:make_questions_from_hash_and_user)
      expect(SecurityQuestion).to receive(:errors_for_questions_list!)

      # In the controller current_user recreates the user object based on a user id
      # in the session, so we have to stub current_user here to make sure the controller
      # is using the same object
      allow(controller).to receive(:current_user).and_return @student.user
      expect(@student.user).to receive(:update_security_questions!)

      put :update, @params_for_update
    end

    it "redirects the user to their home page once they set their security questions" do
      put :update, @params_for_update

      expect(@response).to redirect_to(root_path)
    end

    it "does not accept invalid question values" do
      expect(SecurityQuestion).to receive(:errors_for_questions_list!).and_return(["Wicked bad errors!"])

      put :update, @params_for_update

      expect(flash[:error]).to include("Wicked bad errors!")
      assert_template "edit"
    end
  end

end
