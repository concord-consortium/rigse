require "spec_helper"

describe SecurityQuestion do
  # Class methods
  describe "self.fill_array" do
  end
  
  describe "self.make_questions_from_hash_and_user" do
    before(:each) do
      @hash = {
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
      
      @user = Factory.create(:user)
    end
    
    it "makes a new set of questions according to provided information" do
      new_questions = SecurityQuestion.make_questions_from_hash_and_user(@hash)
      
      new_questions.size.should == 3
      
      @hash.each do |k, v|
        new_questions.select { |q| q.question == SecurityQuestion::QUESTIONS[v[:question_idx]] && q.answer == v[:answer] }.size.should == 1
      end
    end
    
    it "uses information from the user's existing security questions, if appropriate" do
      question = SecurityQuestion.create({ :question => "Existing question", :answer => "existing answer" })
      @user.security_questions << question
      
      @hash[:question2][:question_idx] = "current"
      @hash[:question2][:id] = question.id
      
      new_questions = SecurityQuestion.make_questions_from_hash_and_user(@hash, @user)
      
      new_questions.size.should == 3
      
      new_questions.select { |q| q.question == SecurityQuestion::QUESTIONS[@hash[:question0][:question_idx]] && q.answer == @hash[:question0][:answer] }.size.should == 1
      new_questions.select { |q| q.question == SecurityQuestion::QUESTIONS[@hash[:question1][:question_idx]] && q.answer == @hash[:question1][:answer] }.size.should == 1
      
      # The question should remain the same, but the answer should be updated with the one received in the hash.
      new_questions.select { |q| q.question == question.question && q.answer == @hash[:question2][:answer] }.size.should == 1
    end
  end
  
  describe "self.errors_for_questions_list!" do
    before(:each) do
      @questions = [
        SecurityQuestion.new({ :question => "First test", :answer => "test" }),
        SecurityQuestion.new({ :question => "Second test", :answer => "test" }),
        SecurityQuestion.new({ :question => "Third test", :answer => "test" })
      ]
    end
    
    it "does not accept the same question twice" do
      @questions[2] = @questions[1]
      
      errors = SecurityQuestion.errors_for_questions_list!(@questions)
      
      errors.should include(SecurityQuestion::ERROR_DUPLICATE_QUESTIONS)
    end
    
    it "does not accept fewer than three questions" do
      @questions.pop
      
      errors = SecurityQuestion.errors_for_questions_list!(@questions)
      
      errors.should include(SecurityQuestion::ERROR_TOO_FEW_QUESTIONS)
    end
    
    it "does not accept empty answers" do
      @questions[2].answer = ""
      
      errors = SecurityQuestion.errors_for_questions_list!(@questions)
      
      errors.should include(SecurityQuestion::ERROR_BLANK_ANSWER)
    end
  end
  
  # Instance methods
  describe "question index" do
  end
  
  describe "form options" do
  end
end
