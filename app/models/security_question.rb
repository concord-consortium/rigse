class SecurityQuestion < ActiveRecord::Base
    belongs_to :user
    
    validates_presence_of :user_id
    validates_presence_of :question
    validates_presence_of :answer
    
    QUESTIONS = [
      "What is the name of your favorite pet?",
      "What is your favorite color?",
      "What is your favorite food?"
    ]
    
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
end
