class SecurityQuestion < ActiveRecord::Base
    belongs_to :user
    
    validates_presence_of :user_id
    validates_presence_of :question
    validates_presence_of :answer
    
    QUESTIONS = [
      "What is your favorite color?",
      "What is your favorite food?",
      "What is your favorite ice cream flavor?",
      "What is your pet's name?",
      "What color is your bedroom?",
      "What is your favorite ocean animal?",
      "What is your favorite zoo animal?",
      "What is your favorite farm animal?"
    ]
    
    ERROR_BLANK_ANSWER        = "Answers can't be blank."
    ERROR_TOO_FEW_QUESTIONS   = "You must select three questions."
    ERROR_DUPLICATE_QUESTIONS = "You can't use the same question twice."
    
    def question_idx
      SecurityQuestion::QUESTIONS.index(self.question)
    end
    
    def select_options
      options = []
      if self.question && !self.question.empty?
        options << "<option value=\"current\" selected>#{self.question}</option>" unless self.id.nil?
      else
        options << "<option value=\"\">- Please select a question</option>"
      end
      
      SecurityQuestion::QUESTIONS.each_with_index do |q, i|
        if q != self.question
          options << "<option value=\"#{i}\">#{q}</option>"
        elsif self.id.nil?
          options << "<option value=\"#{i}\" selected>#{q}</option>"
        end
      end
      
      options
    end
    
    def self.fill_array(questions = [])
      questions += Array.new(3 - questions.size) { |i| SecurityQuestion.new } if questions.size < 3
      questions
    end
    
    def self.make_questions_from_hash_and_user(hash, user = nil)
      hash = hash.with_indifferent_access
      (0..2).to_a.collect do |i|
        data = hash["question#{i}"]
        next if data.nil?

        existing_object = user.security_questions.find_by_id(data[:id]) if user && data[:id] && data[:question_idx] == "current"

        if existing_object.nil?
          new_question = SecurityQuestion::QUESTIONS[data[:question_idx].to_i] if data[:question_idx].to_i.to_s == data[:question_idx].to_s
          next if new_question.nil?
        else
          new_question = existing_object.question
        end

        SecurityQuestion.new({ :question => new_question, :answer => data[:answer] })
      end.compact
    end
    
    # This method gets a bang because it will add errors to SecurityQuestions if necessary.
    # Return value here is negative: !errors_for_questions_list!() == OK, anything else == failure. -- Cantina-CMH 6/17/10
    def self.errors_for_questions_list!(questions = [])
      valid = true
      errors = []

      questions.each do |q|
        if q.answer.empty?
          errors << ERROR_BLANK_ANSWER
          q.errors.add :answer, ERROR_BLANK_ANSWER
          valid = false
        end
      end

      if questions.size < 3
        errors << ERROR_TOO_FEW_QUESTIONS
        valid = false
      end

      if questions.collect { |q| q.question }.uniq.size < questions.size
        errors << ERROR_DUPLICATE_QUESTIONS
        valid = false
      end
      return errors
    end
    
    
    # def self.check_questions_list!(questions = [])
    #   valid = true
    #   questions.each do |q|
    #     if q.answer.empty?
    #       errors = "<li>#{ERROR_BLANK_ANSWER}</li>"
    #       q.errors.add :answer, "can't be blank"
    #       valid = false
    #     end
    #   end
    # end
end
