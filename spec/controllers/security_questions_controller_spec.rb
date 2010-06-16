require 'spec_helper'

describe SecurityQuestionsController do
  integrate_views
  
  before(:each) do
    generate_default_project_and_jnlps_with_mocks
    generate_portal_resources_with_mocks
    Admin::Project.stub!(:default_project).and_return(@mock_project)
    
    @student = Factory.create(:portal_student, :user => Factory.create(:user))
    stub_current_user @student.user
  end
  
  describe "GET edit" do
    it "fills in the form with the student's current security questions, if any" do
      @student.user.security_questions.create({ :question => "Test question 1", :answer => "test answer 1" })
      @student.user.security_questions.create({ :question => "Test question 2", :answer => "test answer 2" })
      
      get :edit
      
      @student.user.security_questions.each_with_index do |q, i|
        with_tag("select[name=?]", "question#{i}[question_idx]") do
          with_tag("option[value='current']", :text => q.question_idx)
        end
        with_tag("input[value=?]", q.answer)
      end
    end
  end
  
  describe "PUT update" do
    before(:each) do
      @params_for_update = {
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
      }.with_indifferent_access
    end
    
    describe "make_questions_from_params" do
      it "makes a new set of questions according to param information" do
        @controller.stub!(:params).and_return(@params_for_update)
        @new_questions = @controller.send(:make_questions_from_params)
        
        @new_questions.size.should == 3
        
        @params_for_update.each do |k, v|
          @new_questions.select { |q| q.question == SecurityQuestion::QUESTIONS[v[:question_idx]] && q.answer == v[:answer] }.size.should == 1
        end
      end
      
      it "uses information from the user's existing security questions, if appropriate" do
        question = SecurityQuestion.create({ :question => "Existing question", :answer => "existing answer" })
        @student.user.security_questions << question
        @params_for_update[:question2][:question_idx] = "current"
        @params_for_update[:question2][:id] = question.id
        
        @controller.stub!(:params).and_return(@params_for_update)
        @new_questions = @controller.send(:make_questions_from_params)
        
        @new_questions.size.should == 3
        
        @new_questions.select { |q| q.question == SecurityQuestion::QUESTIONS[@params_for_update[:question0][:question_idx]] && q.answer == @params_for_update[:question0][:answer] }.size.should == 1
        @new_questions.select { |q| q.question == SecurityQuestion::QUESTIONS[@params_for_update[:question1][:question_idx]] && q.answer == @params_for_update[:question1][:answer] }.size.should == 1
        @new_questions.select { |q| q.question == question.question && q.answer == @params_for_update[:question2][:answer] }.size.should == 1
      end
    end
    
    it "updates the user's security questions" do
      @student.user.security_questions.should be_empty
      
      put :update, @params_for_update.clone
      
      @student.user.security_questions.size.should == 3
      @params_for_update.each do |k, v|
        @student.user.security_questions.select { |q| q.question == SecurityQuestion::QUESTIONS[v[:question_idx]] && q.answer == v[:answer] }.size.should == 1
      end
    end
    
    it "redirects the user to their home page once they set their security questions" do
      put :update, @params_for_update
      
      @response.should redirect_to(root_path)
    end
    
    it "does not allow the user to use the same question twice" do
      @params_for_update[:question2][:question_idx] = @params_for_update[:question1][:question_idx]
      
      put :update, @params_for_update
      
      flash[:error].should include(SecurityQuestionsController::ERROR_DUPLICATE_QUESTIONS)
      assert_template "edit"
    end
    
    it "requires the user to set all three questions" do
      @params_for_update[:question2][:question_idx] = nil
      
      put :update, @params_for_update
      
      flash[:error].should include(SecurityQuestionsController::ERROR_TOO_FEW_QUESTIONS)
      assert_template "edit"
    end
    
    it "does not allow the user to use empty answers" do
      @params_for_update[:question2][:answer] = ""
      
      put :update, @params_for_update
      
      flash[:error].should include(SecurityQuestionsController::ERROR_BLANK_ANSWER)
      assert_template "edit"
    end
  end

end