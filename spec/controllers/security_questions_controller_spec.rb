require "spec_helper"

describe SecurityQuestionsController do
  integrate_views
  
  before(:each) do
    @student = Factory.create(:portal_student, :user => Factory.create(:user))
    stub_current_user @student.user

    controller.stub(:before_render) {
      response.template.stub_chain(:current_project, :name).and_return("Test Project")
    }
  end
  
  describe "GET edit" do
    it "fills in the form with the student's current security questions, if any" do
      @student.user.security_questions.create({ :question => "Test question 1", :answer => "test answer 1" })
      @student.user.security_questions.create({ :question => "Test question 2", :answer => "test answer 2" })
      
      get :edit
      
      @student.user.security_questions.each_with_index do |q, i|
        with_tag("select[name=?]", "security_questions[question#{i}][question_idx]") do
          with_tag("option[value='current']", :text => q.question_idx)
        end
        with_tag("input[name=?][value=?]", "security_questions[question#{i}][answer]", q.answer)
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
      SecurityQuestion.should_receive(:make_questions_from_hash_and_user)
      SecurityQuestion.should_receive(:errors_for_questions_list!)
      @student.user.should_receive(:update_security_questions!)
      
      put :update, @params_for_update
    end
    
    it "redirects the user to their home page once they set their security questions" do
      put :update, @params_for_update
      
      @response.should redirect_to(root_path)
    end
    
    it "does not accept invalid question values" do
      SecurityQuestion.should_receive(:errors_for_questions_list!).and_return(["Wicked bad errors!"])
      
      put :update, @params_for_update
      
      flash[:error].should include("Wicked bad errors!")
      assert_template "edit"
    end
  end

end
