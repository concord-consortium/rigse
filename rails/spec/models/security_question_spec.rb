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
      
      @user = FactoryBot.create(:user)
    end
    
    it "makes a new set of questions according to provided information" do
      new_questions = SecurityQuestion.make_questions_from_hash_and_user(@hash)
      
      expect(new_questions.size).to eq(3)
      
      @hash.each do |k, v|
        expect(new_questions.select { |q| q.question == SecurityQuestion::QUESTIONS[v[:question_idx]] && q.answer == v[:answer] }.size).to eq(1)
      end
    end
    
    it "uses information from the user's existing security questions, if appropriate" do
      question = SecurityQuestion.create({ :question => "Existing question", :answer => "existing answer" })
      @user.security_questions << question
      
      @hash[:question2][:question_idx] = "current"
      @hash[:question2][:id] = question.id
      
      new_questions = SecurityQuestion.make_questions_from_hash_and_user(@hash, @user)
      
      expect(new_questions.size).to eq(3)
      
      expect(new_questions.select { |q| q.question == SecurityQuestion::QUESTIONS[@hash[:question0][:question_idx]] && q.answer == @hash[:question0][:answer] }.size).to eq(1)
      expect(new_questions.select { |q| q.question == SecurityQuestion::QUESTIONS[@hash[:question1][:question_idx]] && q.answer == @hash[:question1][:answer] }.size).to eq(1)
      
      # The question should remain the same, but the answer should be updated with the one received in the hash.
      expect(new_questions.select { |q| q.question == question.question && q.answer == @hash[:question2][:answer] }.size).to eq(1)
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
      
      expect(errors).to include(SecurityQuestion::ERROR_DUPLICATE_QUESTIONS)
    end
    
    it "does not accept fewer than three questions" do
      @questions.pop
      
      errors = SecurityQuestion.errors_for_questions_list!(@questions)
      
      expect(errors).to include(SecurityQuestion::ERROR_TOO_FEW_QUESTIONS)
    end
    
    it "does not accept empty answers" do
      @questions[2].answer = ""
      
      errors = SecurityQuestion.errors_for_questions_list!(@questions)
      
      expect(errors).to include(SecurityQuestion::ERROR_BLANK_ANSWER)
    end
  end
  
  # Instance methods
  describe "question index" do
  end
  
  describe "form options" do
  end


  # TODO: auto-generated
  describe '#question_idx' do
    it 'question_idx' do
      security_question = described_class.new
      result = security_question.question_idx

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#select_options' do
    it 'select_options' do
      security_question = described_class.new
      result = security_question.select_options

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.fill_array' do
    it 'fill_array' do
      questions = []
      result = described_class.fill_array(questions)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.make_questions_from_hash_and_user' do
    it 'make_questions_from_hash_and_user' do
      hash = {}
      user = FactoryBot.create(:user)
      result = described_class.make_questions_from_hash_and_user(hash, user)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.errors_for_questions_list!' do
    it 'errors_for_questions_list!' do
      questions = []
      result = described_class.errors_for_questions_list!(questions)

      expect(result).not_to be_nil
    end
  end


end
